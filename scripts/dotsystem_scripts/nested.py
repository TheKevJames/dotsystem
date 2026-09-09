"""
Generic access and merge for nested dict/list structures.

Shared by the YAML (ruamel) and TOML (tomlkit) paths: both expose their
containers as plain `dict`/`list` subclasses, so these helpers narrow on the
builtins and stay agnostic of the concrete node type. Paths are addressed with
segment lists as produced by `parse_path`.
"""

import re

import tomlkit


def parse_path(path: str) -> list[str | int]:
    tokens = re.findall(r'[^.\[\]]+|\[\d+\]', path)
    return [int(t[1:-1]) if t[0] == '[' else t for t in tokens]


def index_into(node: object, key: str | int) -> object:
    if isinstance(node, dict):
        return node[key]
    if isinstance(node, list) and isinstance(key, int):
        return node[key]
    raise KeyError(key)


def assign_into(node: object, key: str | int, value: object) -> None:
    if isinstance(node, dict):
        node[key] = value
    elif isinstance(node, list) and isinstance(key, int):
        node[key] = value
    else:
        raise KeyError(key)


def get_at(data: object, segments: list[str | int]) -> object:
    for segment in segments:
        data = index_into(data, segment)
    return data


def has_at(data: object, segments: list[str | int]) -> bool:
    try:
        get_at(data, segments)
    except (KeyError, IndexError):
        return False
    return True


def set_at(data: object, segments: list[str | int], value: object) -> None:
    node = get_at(data, segments[:-1])
    assign_into(node, segments[-1], value)


def set_at_create(
    data: object, segments: list[str | int], value: object
) -> None:
    node = data
    for segment in segments[:-1]:
        if not isinstance(node, dict):
            raise KeyError(segment)
        if segment not in node:
            node[segment] = tomlkit.table()
        node = node[segment]
    assign_into(node, segments[-1], value)


def union_extend(target: list[object], source: list[object]) -> None:
    for item in source:
        if item not in target:
            target.append(item)


def deep_merge(target: dict[str, object], source: dict[str, object]) -> None:
    """Key-wise merge tables; order-preserving deduplicated union for lists."""
    for key, value in source.items():
        existing = target.get(key)
        if isinstance(value, dict) and isinstance(existing, dict):
            deep_merge(existing, value)
        elif isinstance(value, list) and isinstance(existing, list):
            union_extend(existing, value)
        else:
            target[key] = value


def merge_at(
    target: object, source: object, segments: list[str | int]
) -> None:
    value = get_at(source, segments)
    if not has_at(target, segments):
        set_at_create(target, segments, value)
        return
    existing = get_at(target, segments)
    if isinstance(value, list) and isinstance(existing, list):
        union_extend(existing, value)
    elif isinstance(value, dict) and isinstance(existing, dict):
        deep_merge(existing, value)
    else:
        set_at(target, segments, value)


def prune_at(target: object, segments: list[str | int]) -> None:
    """Delete the leaf and any ancestor tables left empty by its removal."""
    parents: list[object] = [target]
    for segment in segments[:-1]:
        node = parents[-1]
        if not isinstance(node, dict):
            return
        parents.append(node[segment])
    for depth in range(len(segments) - 1, -1, -1):
        container = parents[depth]
        if not isinstance(container, dict):
            return
        del container[segments[depth]]
        if container:
            return


def unmerge_at(
    target: object, source: object, segments: list[str | int]
) -> None:
    if not has_at(target, segments):
        return
    value = get_at(source, segments)
    existing = get_at(target, segments)
    empty = True
    if isinstance(value, list) and isinstance(existing, list):
        for item in value:
            if item in existing:
                existing.remove(item)
        empty = not existing
    elif isinstance(value, dict) and isinstance(existing, dict):
        for key in value:
            if key in existing:
                del existing[key]
        empty = not existing
    if empty:
        prune_at(target, segments)

"""
Model and IO for the shared dotsystem repo template.

Template data lives under $XDG_CONFIG_HOME/repo-template (falling back to
~/.config/repo-template); its tracked working copy is this repo's
root/~/.config/repo-template. config.toml declares paths removed from the
template (deleted from targets on sync), per-file templated strategies, and
per-feature install metadata. This module reads that store and writes files
into targets; the feature engine and CLI build on it.
"""

import difflib
import enum
import io
import pathlib
import tomllib
from typing import Required
from typing import TypedDict

import ruamel.yaml
import tomlkit
import typer

from . import nested

CONFIG_NAME = 'config.toml'
FEATURES_DIRNAME = 'features'

# Top-level entries under the template dir that sync handles specially rather
# than copying wholesale into the target.
RESERVED = frozenset({CONFIG_NAME, FEATURES_DIRNAME})

PRECOMMIT_CONFIG = '.pre-commit-config.yaml'

# varpath -> {'derive'|'prompt': value}
Spec = dict[str, dict[str, str]]


class FeatureSpec(TypedDict, total=False):
    placement: Required[str]
    exclude_hooks: list[str]
    merge: dict[str, list[str]]  # relative filename -> merged toml key-paths


yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.width = 4096


class Feature(enum.StrEnum):
    DOCKER = 'docker'
    PYTHON = 'python'
    SHELL = 'shell'
    TERRAFORM = 'terraform'


class Placement(enum.StrEnum):
    ROOT = 'root'
    SUBDIR = 'subdir'


def source_dir() -> pathlib.Path:
    # TODO: swap to xdg paths after testing the script fully
    # return paths.resolve_base(
    #     'XDG_CONFIG_HOME', pathlib.Path.home() / '.config',
    #     'repo-template',
    # )
    config = pathlib.Path.home() / 'src/personal/dotsystem/root/~/.config'
    base = pathlib.Path(config) if config else pathlib.Path.home() / '.config'
    return base / 'repo-template'


def features_config() -> dict[str, FeatureSpec]:
    config = source_dir() / CONFIG_NAME
    if not config.exists():
        return {}
    features: dict[str, FeatureSpec] = tomllib.loads(config.read_text()).get(
        FEATURES_DIRNAME, {}
    )
    return features


def feature_dir(feature: Feature) -> pathlib.Path:
    return source_dir() / FEATURES_DIRNAME / feature.value


def feature_placement(feature: Feature) -> Placement:
    return Placement(features_config()[feature.value]['placement'])


def deleted_paths() -> list[str]:
    config = source_dir() / CONFIG_NAME
    if not config.exists():
        return []
    deleted: list[str] = tomllib.loads(config.read_text()).get('deleted', [])
    return deleted


def templated_files() -> dict[str, Spec]:
    config = source_dir() / CONFIG_NAME
    if not config.exists():
        return {}
    files: dict[str, Spec] = tomllib.loads(config.read_text()).get(
        'templated', {}
    )
    return files


def sync_file(content: str, dest: pathlib.Path) -> None:
    if dest.exists():
        diff = difflib.unified_diff(
            dest.read_text().splitlines(keepends=True),
            content.splitlines(keepends=True),
            fromfile=str(dest),
            tofile=f'{dest} (template)',
        )
        diff_text = ''.join(diff)
        if not diff_text:
            return

        typer.echo(diff_text)
        if not typer.confirm(f'Overwrite {dest}?'):
            typer.echo(f'Skipped {dest}')
            return

    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(content)
    typer.echo(f'Wrote {dest}')


def sync_yaml(data: object, dest: pathlib.Path) -> None:
    stream = io.StringIO()
    yaml.dump(data, stream)
    sync_file(stream.getvalue(), dest)


def delete_file(dest: pathlib.Path) -> None:
    if not dest.exists():
        return

    if not typer.confirm(f'Delete {dest}?'):
        typer.echo(f'Kept {dest}')
        return

    dest.unlink()
    typer.echo(f'Deleted {dest}')


def merge_toml(
    src: pathlib.Path, dest: pathlib.Path, paths: list[str], *, add: bool
) -> None:
    if not add and not dest.exists():
        return
    source = tomlkit.parse(src.read_text())
    target = (
        tomlkit.parse(dest.read_text())
        if dest.exists()
        else tomlkit.document()
    )
    for path in paths:
        segments = nested.parse_path(path)
        if add:
            nested.merge_at(target, source, segments)
        else:
            nested.unmerge_at(target, source, segments)
    sync_file(tomlkit.dumps(target), dest)

"""
Feature engine: install, remove, and detect a feature in a target repo.

A feature transforms the target's pre-commit config. A subdir feature carries
its own copied config and unions its install site into named hooks' `exclude`
regexes; a root feature merges a `.pre-commit-config.yaml` fragment (its repo
blocks) into the shared root config. A feature placed "any" works as a subdir
feature in a subdir, and at the root swaps its fragment's repo blocks in for
the root config's own copies of its `exclude_hooks`. A feature is installed
wherever any of those changes are present; a root feature without a fragment
(eg. one that only adds files) is installed wherever any of its files are.
"""

import copy
import pathlib
import re

import typer
from ruamel.yaml import comments
from ruamel.yaml import error
from ruamel.yaml import scalarstring
from ruamel.yaml import tokens

from . import splice
from . import template
from . import trailing

# One group per install site in a hook's `exclude` union, e.g.
# `(^scripts/.*)|(^libs/foo/.*)`; the brackets keep it parseable back to paths.
EXCLUDE_GROUP = re.compile(r'\(\^(.*)/\.\*\)')

# A root feature's block group is led by a `# <feature>` comment line.
FEATURE_MARKER = re.compile(r'^#\s*(\S+)\s*$')

CommentSlot = tokens.CommentToken | list[tokens.CommentToken] | None


def iter_hooks(config: comments.CommentedMap) -> list[comments.CommentedMap]:
    return [
        hook
        for repo in config.get('repos', [])
        for hook in repo.get('hooks', [])
    ]


def parse_exclude(value: str) -> list[str]:
    return [
        m.group(1)
        for part in value.split('|')
        if (m := EXCLUDE_GROUP.fullmatch(part))
    ]


def build_exclude(paths: set[str]) -> scalarstring.SingleQuotedScalarString:
    # Single-quote so re-syncs match hand-written configs and don't churn.
    union = '|'.join(f'(^{path}/.*)' for path in sorted(paths))
    return scalarstring.SingleQuotedScalarString(union)


def assign_hook_exclude(hook: comments.CommentedMap, paths: set[str]) -> None:
    # Comment lines after the hook hang off its last key, which `exclude` may
    # become or stop being; keep them after the hook.
    following = trailing.pop(hook)
    if paths:
        hook['exclude'] = build_exclude(paths)
    elif 'exclude' in hook:
        del hook['exclude']
    trailing.push(hook, following)


def edit_excludes(
    root: pathlib.Path, hook_ids: list[str], relpath: str, *, add: bool
) -> None:
    config_path = root / template.PRECOMMIT_CONFIG
    if not hook_ids or not config_path.exists():
        return
    config = template.yaml.load(config_path)
    for hook in iter_hooks(config):
        if hook.get('id') not in hook_ids:
            continue
        paths = set(parse_exclude(hook.get('exclude', '')))
        assign_hook_exclude(
            hook, paths | {relpath} if add else paths - {relpath}
        )
    template.sync_yaml(config, config_path)


def fragment_urls(fragment: comments.CommentedMap) -> set[str]:
    repos = fragment.get('repos', [])
    return {repo['repo'] for repo in repos if 'repo' in repo}


def root_fragment_urls() -> dict[str, set[str]]:
    """Repo URLs each root feature contributes, keyed by feature name."""
    urls: dict[str, set[str]] = {}
    for feature in template.Feature:
        if template.feature_placement(feature) is not template.Placement.ROOT:
            continue
        path = template.feature_dir(feature) / template.PRECOMMIT_CONFIG
        if path.exists():
            urls[feature.value] = fragment_urls(template.yaml.load(path))
    return urls


def present_root_features(config: comments.CommentedMap) -> set[str]:
    present = {repo.get('repo') for repo in config.get('repos', [])}
    return {
        name for name, urls in root_fragment_urls().items() if urls & present
    }


def _strip_marker(value: str, names: set[str]) -> str | None:
    kept: list[str] = []
    for line in value.split('\n'):
        match = FEATURE_MARKER.match(line.strip())
        if match and match.group(1) in names:
            if kept and not kept[-1].strip():
                kept.pop()
            continue
        kept.append(line)
    text = '\n'.join(kept)
    return text if text.strip() else None


def _clean_token(
    token: tokens.CommentToken | None, names: set[str]
) -> tokens.CommentToken | None:
    if token is None:
        return None
    cleaned = _strip_marker(token.value, names)
    if cleaned is None:
        return None
    token.value = cleaned
    return token


def _clean_slot(slot: CommentSlot, names: set[str]) -> CommentSlot:
    if isinstance(slot, list):
        return [
            token
            for token in (_clean_token(t, names) for t in slot)
            if token is not None
        ]
    return _clean_token(slot, names)


def strip_feature_markers(node: object, names: set[str]) -> None:
    """
    Remove round-tripped `# <feature>` markers from every comment in `node`.

    ruamel reattaches a merged block's leading marker to the previous block's
    last leaf on reload, so a stale marker can surface anywhere in the tree;
    rebuilds re-add fresh ones over the cleaned core blocks.
    """
    ca = getattr(node, 'ca', None)
    if ca is not None and ca.items:
        for key in list(ca.items):
            ca.items[key] = [
                _clean_slot(slot, names) for slot in ca.items[key]
            ]
    if isinstance(node, dict):
        for value in node.values():
            strip_feature_markers(value, names)
    elif isinstance(node, list):
        for value in node:
            strip_feature_markers(value, names)


def rebuild_root_fragments(
    config: comments.CommentedMap,
    installed: set[str],
    rev_source: comments.CommentedMap,
) -> None:
    """
    Rewrite `config`'s repos as core blocks plus installed root features.

    Feature groups are ordered alphabetically and each is led by a blank line
    and a `# <feature>` comment, so the result is independent of the order
    features were installed. A present repo keeps its installed `rev` (renovate
    may bump it) from `rev_source` while its hooks refresh from the fragment.
    """
    urls_by_feature = root_fragment_urls()
    feature_urls = set().union(*urls_by_feature.values())
    revs = {
        repo['repo']: repo['rev']
        for repo in rev_source.get('repos', [])
        if 'repo' in repo and 'rev' in repo
    }
    core = comments.CommentedSeq()
    for repo in config.get('repos', comments.CommentedSeq()):
        if repo.get('repo') not in feature_urls:
            core.append(repo)
    strip_feature_markers(core, set(urls_by_feature))
    for name in sorted(installed & urls_by_feature.keys()):
        fragment = template.yaml.load(
            template.feature_dir(template.Feature(name))
            / template.PRECOMMIT_CONFIG
        )
        first = len(core)
        for repo in fragment.get('repos', []):
            block = copy.deepcopy(repo)
            block['rev'] = revs.get(repo['repo'], repo.get('rev'))
            core.append(block)
        core.ca.items[first] = [
            None,
            [tokens.CommentToken(f'\n# {name}\n', error.CommentMark(0), None)],
            None,
            None,
        ]
    config['repos'] = core


def base_owned_repos(hook_ids: set[str]) -> list[comments.CommentedMap]:
    """The base template's repo blocks, cut down to the `hook_ids` hooks."""
    base = template.yaml.load(
        template.source_dir() / template.PRECOMMIT_CONFIG
    )
    repos: list[comments.CommentedMap] = []
    for repo in base.get('repos', []):
        hooks = repo.get('hooks', [])
        for idx in reversed(range(len(hooks))):
            if hooks[idx].get('id') not in hook_ids:
                del hooks[idx]
        if hooks:
            repos.append(repo)
    return repos


def splice_root_feature(
    feature: template.Feature,
    config: comments.CommentedMap,
    rev_source: comments.CommentedMap,
    *,
    add: bool,
) -> None:
    """
    Install a feature placed "any" at the root of `config`.

    Every root hook the feature owns (its `exclude_hooks`, and its fragment's
    hooks) is replaced by the fragment's repo blocks, or by the base
    template's when `add` is False, so the result does not depend on what was
    installed before. Revs come from `rev_source` where it has the repo, so
    renovate bumps survive, and subdir sites stay excluded from the new hooks.
    """
    hook_ids = set(
        template.features_config()[feature.value].get('exclude_hooks', [])
    )
    fragment = template.yaml.load(
        template.feature_dir(feature) / template.PRECOMMIT_CONFIG
    )
    revs = {
        repo['repo']: repo['rev']
        for repo in rev_source.get('repos', [])
        if 'repo' in repo and 'rev' in repo
    }
    sites = {
        path
        for hook in iter_hooks(config)
        if hook.get('id') in hook_ids
        for path in parse_exclude(hook.get('exclude', ''))
    }
    if 'repos' not in config:
        config['repos'] = comments.CommentedSeq()
    holes = splice.take_hooks(
        config['repos'],
        hook_ids | {hook['id'] for hook in iter_hooks(fragment)},
    )
    new: list[comments.CommentedMap] = []
    for repo in fragment['repos'] if add else base_owned_repos(hook_ids):
        block = copy.deepcopy(repo)
        trailing.pop(block)
        if 'rev' in block:
            block['rev'] = revs.get(block['repo'], block['rev'])
        for hook in block['hooks']:
            if hook.get('id') in hook_ids:
                assign_hook_exclude(hook, sites)
        new.append(block)
    splice.place_blocks(config['repos'], holes, new)


def root_install_present(
    feature: template.Feature, config: comments.CommentedMap
) -> bool:
    """Whether `config` has repos only `feature`'s root install brings."""
    fragment_path = template.feature_dir(feature) / template.PRECOMMIT_CONFIG
    base_path = template.source_dir() / template.PRECOMMIT_CONFIG
    if not fragment_path.exists() or not base_path.exists():
        return False
    urls = fragment_urls(template.yaml.load(fragment_path)) - fragment_urls(
        template.yaml.load(base_path)
    )
    present = {repo.get('repo') for repo in config.get('repos', [])}
    return bool(urls & present)


def files_present(feature: template.Feature, root: pathlib.Path) -> bool:
    """Whether any file of a fragment-less feature exists under `root`."""
    source = template.feature_dir(feature)
    if (source / template.PRECOMMIT_CONFIG).exists():
        return False
    return any(
        (root / path.relative_to(source)).is_file()
        for path in source.rglob('*')
        if path.is_file()
    )


def fragment_present(
    feature: template.Feature, config: comments.CommentedMap
) -> bool:
    fragment_path = template.feature_dir(feature) / template.PRECOMMIT_CONFIG
    if not fragment_path.exists():
        return False
    urls = fragment_urls(template.yaml.load(fragment_path))
    present = {repo.get('repo') for repo in config.get('repos', [])}
    return bool(urls & present)


def apply_fragment(
    feature: template.Feature, dest: pathlib.Path, *, add: bool
) -> None:
    config = (
        template.yaml.load(dest) if dest.exists() else comments.CommentedMap()
    )
    installed = present_root_features(config)
    if add:
        installed.add(feature.value)
    else:
        installed.discard(feature.value)
    rebuild_root_fragments(config, installed, config)
    template.sync_yaml(config, dest)


def sync_precommit(
    src: pathlib.Path, dest: pathlib.Path, sites: dict[str, set[str]]
) -> None:
    """
    Rewrite the root config, baking every installed feature's changes at once.

    The base template carries no feature changes, so a plain sync would strip a
    subdir feature's exclude unions (which also encode its install sites) and a
    root feature's merged fragment. Fragment revs are read from the existing
    `dest` (pre-overwrite) so renovate bumps survive the sync.
    """
    config = template.yaml.load(src)
    existing = (
        template.yaml.load(dest) if dest.exists() else comments.CommentedMap()
    )
    for feature in template.Feature:
        placement = template.feature_placement(feature)
        if placement is template.Placement.ROOT:
            continue
        feature_sites = sites.get(feature.value) or set()
        if '.' in feature_sites:
            splice_root_feature(feature, config, existing, add=True)
        hook_ids = template.features_config()[feature.value].get(
            'exclude_hooks', []
        )
        for hook in iter_hooks(config):
            if hook.get('id') in hook_ids:
                assign_hook_exclude(hook, feature_sites - {'.'})
    installed = {
        feature.value
        for feature in template.Feature
        if template.feature_placement(feature) is template.Placement.ROOT
        and sites.get(feature.value)
    }
    rebuild_root_fragments(config, installed, existing)
    template.sync_yaml(config, dest)


def installed_sites(
    root: pathlib.Path, feature: template.Feature
) -> list[str]:
    """Relpaths where `feature` is installed; a root install sits at '.'."""
    config_path = root / template.PRECOMMIT_CONFIG
    if not config_path.exists():
        return []
    config = template.yaml.load(config_path)
    placement = template.feature_placement(feature)
    if placement is template.Placement.ROOT:
        present = fragment_present(feature, config) or files_present(
            feature, root
        )
        return ['.'] if present else []
    paths: set[str] = set()
    if placement is template.Placement.ANY and root_install_present(
        feature, config
    ):
        paths.add('.')
    hook_ids = template.features_config()[feature.value].get(
        'exclude_hooks', []
    )
    if not hook_ids:
        return sorted(paths)
    for hook in iter_hooks(config):
        if hook.get('id') in hook_ids:
            paths.update(parse_exclude(hook.get('exclude', '')))
    return sorted(paths)


def feature_installed(
    feature: template.Feature, root: pathlib.Path, target: pathlib.Path
) -> bool:
    """Whether `feature` is installed at `target` (root features at '.')."""
    relpath = target.resolve().relative_to(root.resolve()).as_posix()
    return relpath in installed_sites(root, feature)


def validate_placement(
    feature: template.Feature, root: pathlib.Path, target: pathlib.Path
) -> None:
    if not (root / template.PRECOMMIT_CONFIG).exists():
        raise typer.BadParameter(
            f'{target} is not inside a synced repo', param_hint='target'
        )
    at_root = target.resolve() == root.resolve()
    placement = template.feature_placement(feature)
    if placement is template.Placement.ROOT and not at_root:
        raise typer.BadParameter(
            f'{feature.value} must target the repo root', param_hint='target'
        )
    if placement is template.Placement.SUBDIR and at_root:
        raise typer.BadParameter(
            f'{feature.value} must target a subdirectory, not the repo root',
            param_hint='target',
        )


def apply_feature(
    feature: template.Feature,
    root: pathlib.Path,
    subdir: pathlib.Path,
    *,
    add: bool,
) -> None:
    """Install a feature into a subdir or the root; `add`=False removes it."""
    config = template.features_config().get(feature.value, {})
    placement = template.feature_placement(feature)
    at_root = subdir.resolve() == root.resolve()
    merges: dict[str, list[str]] = config.get('merge', {})
    source = template.feature_dir(feature)
    for path in sorted(source.rglob('*')):
        if not path.is_file():
            continue
        rel = str(path.relative_to(source))
        dest = subdir / rel
        # A subdir feature carries its own copied config; a root feature's
        # config is a fragment merged into the shared root config instead.
        is_root_fragment = (
            rel == template.PRECOMMIT_CONFIG
            and placement is template.Placement.ROOT
        )
        if is_root_fragment:
            apply_fragment(feature, root / template.PRECOMMIT_CONFIG, add=add)
        elif rel == template.PRECOMMIT_CONFIG and at_root:
            root_config = template.yaml.load(dest)
            splice_root_feature(feature, root_config, root_config, add=add)
            template.sync_yaml(root_config, dest)
        elif rel in merges:
            template.merge_toml(path, dest, merges[rel], add=add)
        elif add:
            template.sync_file(path.read_text(), dest)
        else:
            template.delete_file(dest)
    if at_root:
        # A root install keeps its hooks' subdir excludes as they are.
        return
    relpath = subdir.resolve().relative_to(root.resolve()).as_posix()
    edit_excludes(root, config.get('exclude_hooks', []), relpath, add=add)

"""
Update a repo from the shared source of truth.

Copies the template store into a target repo, filling templated variables and
reconciling installed features. See `template` for the model/IO layer and
`features` for the feature engine.
"""

import pathlib
from collections.abc import Callable
from typing import Annotated

import typer
from ruamel.yaml import comments

from . import features
from . import git
from . import nested
from . import template

app = typer.Typer(help=__doc__, no_args_is_help=True, add_completion=False)


def repo_root(subdir: pathlib.Path) -> pathlib.Path:
    toplevel = git.run_git(subdir, 'rev-parse', '--show-toplevel')
    if toplevel is None:
        raise typer.BadParameter(
            f'{subdir} is not inside a git repository', param_hint='target'
        )
    return pathlib.Path(toplevel)


def derive_git_branch(repo: pathlib.Path) -> str | None:
    return git.run_git(repo, 'symbolic-ref', '--short', 'HEAD') or None


DERIVERS: dict[str, Callable[[pathlib.Path], str | None]] = {
    'dirname': lambda repo: repo.resolve().name,
    'git-branch': derive_git_branch,
}


Target = Annotated[
    pathlib.Path,
    typer.Argument(exists=True, file_okay=False, help='repo to update'),
]


def resolve_variables(
    spec: template.Spec,
    repo: pathlib.Path,
    target: comments.CommentedMap | None,
) -> dict[str, object]:
    """
    Value for each variable: kept from target where set, else prompted.

    Variables sharing a derivation source are prompted once and applied to
    every path in the group.
    """
    values: dict[str, object] = {}
    fresh: list[str] = []
    for name in spec:
        segments = nested.parse_path(name)
        if target is not None and nested.has_at(target, segments):
            values[name] = nested.get_at(target, segments)
        else:
            fresh.append(name)

    groups: dict[tuple[str, str], list[str]] = {}
    for name in fresh:
        meta = spec[name]
        if 'derive' in meta:
            source = ('derive', meta['derive'])
        else:
            source = ('prompt', name)
        groups.setdefault(source, []).append(name)

    for (kind, source), names in groups.items():
        meta = spec[names[0]]
        default = DERIVERS[source](repo) if kind == 'derive' else None
        answer = typer.prompt(meta.get('prompt', names[0]), default=default)
        for name in names:
            values[name] = answer

    return values


def sync_templated(
    tmpl: pathlib.Path,
    dest: pathlib.Path,
    spec: template.Spec,
    repo: pathlib.Path,
) -> None:
    data = template.yaml.load(tmpl)
    target = template.yaml.load(dest) if dest.exists() else None

    for name, value in resolve_variables(spec, repo, target).items():
        nested.set_at(data, nested.parse_path(name), value)

    template.sync_yaml(data, dest)


@app.command()
def sync(target: Target = pathlib.Path()) -> None:
    """Sync every template file into the target repo."""
    source = template.source_dir()
    templated = template.templated_files()
    # Sites live in the root config's exclude unions, which the loop rewrites;
    # capture them first or detection afterwards comes up empty.
    sites = {
        feature.value: set(features.installed_sites(target, feature))
        for feature in template.Feature
    }
    for path in sorted(source.rglob('*')):
        relative = path.relative_to(source)
        if relative.parts[0] in template.RESERVED:
            continue
        if not path.is_file():
            continue
        rel = str(relative)
        if rel == template.PRECOMMIT_CONFIG:
            features.sync_precommit(path, target / relative, sites)
        elif rel in templated:
            sync_templated(path, target / relative, templated[rel], target)
        else:
            template.sync_file(path.read_text(), target / relative)
    for name in template.deleted_paths():
        template.delete_file(target / name)
    for feature in template.Feature:
        for relpath in sorted(sites[feature.value]):
            features.apply_feature(feature, target, target / relpath, add=True)


@app.command('add-feature')
def add_feature(
    feature: template.Feature, target: Target = pathlib.Path()
) -> None:
    """Install a feature's templates, merges, and excludes into a subdir."""
    root = repo_root(target)
    features.validate_placement(feature, root, target)
    features.apply_feature(feature, root, target, add=True)


@app.command('remove-feature')
def remove_feature(
    feature: template.Feature, target: Target = pathlib.Path()
) -> None:
    """Reverse an installed feature: delete files, unmerge, drop excludes."""
    root = repo_root(target)
    features.validate_placement(feature, root, target)
    if not features.feature_installed(feature, root, target):
        raise typer.BadParameter(
            f'{feature.value} does not appear to be installed',
            param_hint='target',
        )
    features.apply_feature(feature, root, target, add=False)

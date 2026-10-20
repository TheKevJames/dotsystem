import pathlib

import pytest
import typer

from dotsystem_scripts import features
from dotsystem_scripts import repo_template
from dotsystem_scripts import template

BASE = (template.source_dir() / template.PRECOMMIT_CONFIG).read_text()

ROOT_FEATURES = [
    feature
    for feature in template.Feature
    if template.feature_placement(feature) is template.Placement.ROOT
]


@pytest.fixture(autouse=True, scope='function')
def _auto_confirm(monkeypatch: pytest.MonkeyPatch) -> None:
    # sync_file prompts before overwriting; tests run non-interactively.
    monkeypatch.setattr(typer, 'confirm', lambda *a, **k: True)


def _install(dest: pathlib.Path, order: list[template.Feature]) -> str:
    dest.write_text(BASE)
    for feature in order:
        features.apply_fragment(feature, dest, add=True)
    return dest.read_text()


def test_root_fragments_merge_alphabetically_regardless_of_order(
    tmp_path: pathlib.Path,
) -> None:
    forward = _install(tmp_path / 'a.yaml', ROOT_FEATURES)
    reverse = _install(tmp_path / 'b.yaml', list(reversed(ROOT_FEATURES)))

    assert forward == reverse
    markers = [
        line
        for line in forward.splitlines()
        if line.startswith('# ')
        and line[2:] in {f.value for f in ROOT_FEATURES}
    ]
    assert markers == sorted(markers)
    for feature in ROOT_FEATURES:
        assert f'\n\n# {feature.value}\n' in forward


def test_remove_root_fragment_leaves_no_trace(tmp_path: pathlib.Path) -> None:
    dest = tmp_path / 'c.yaml'
    _install(dest, ROOT_FEATURES)
    dropped = ROOT_FEATURES[0]
    features.apply_fragment(dropped, dest, add=False)
    result = dest.read_text()

    assert f'# {dropped.value}' not in result
    for feature in ROOT_FEATURES[1:]:
        assert f'# {feature.value}' in result


PYTHON = template.Feature.PYTHON
FRAGMENT = template.yaml.load(
    template.feature_dir(PYTHON) / template.PRECOMMIT_CONFIG
)


def _repo(tmp_path: pathlib.Path) -> pathlib.Path:
    root = tmp_path / 'repo'
    (root / 'sub').mkdir(parents=True)
    (root / template.PRECOMMIT_CONFIG).write_text(BASE)
    return root


def _config(root: pathlib.Path) -> str:
    return (root / template.PRECOMMIT_CONFIG).read_text()


def _repo_urls(text: str) -> list[str]:
    return [
        line.split('repo: ', 1)[1]
        for line in text.splitlines()
        if line.startswith('  - repo: ')
    ]


def test_root_python_swaps_generic_hooks_for_fragment(
    tmp_path: pathlib.Path,
) -> None:
    root = _repo(tmp_path)
    features.validate_placement(PYTHON, root, root)
    features.apply_feature(PYTHON, root, root, add=True)
    result = _config(root)
    config = template.yaml.load(root / template.PRECOMMIT_CONFIG)

    urls = _repo_urls(result)
    assert 'https://github.com/PyCQA/pylint' not in urls
    assert 'https://github.com/PyCQA/flake8' not in urls
    assert urls.count('https://github.com/astral-sh/ruff-pre-commit') == 1
    # The fragment's blocks sit where the generic ones were, around refurb.
    assert urls.index('https://github.com/astral-sh/ty-pre-commit') + 2 == (
        urls.index('https://github.com/dosisod/refurb')
    )
    assert urls.index('https://github.com/astral-sh/uv-pre-commit') == (
        urls.index('https://github.com/astral-sh/ruff-pre-commit') + 1
    )
    hooks = {hook['id']: hook for hook in features.iter_hooks(config)}
    fragment_hooks = {
        hook['id']: hook for hook in features.iter_hooks(FRAGMENT)
    }
    for hook_id, hook in fragment_hooks.items():
        assert hooks[hook_id] == hook
    # Comments between blocks and the base's own `# python` marker survive.
    assert (
        '  # TODO: use ruff once more refurb rules are out of preview\n'
        '  - repo: https://github.com/dosisod/refurb\n'
    ) in result
    assert '\n\n# python\n      - id: check-builtin-literals\n' in result
    assert features.installed_sites(root, PYTHON) == ['.']


def test_root_python_add_is_idempotent_and_remove_restores_base(
    tmp_path: pathlib.Path,
) -> None:
    root = _repo(tmp_path)
    features.apply_feature(PYTHON, root, root, add=True)
    installed = _config(root)
    features.apply_feature(PYTHON, root, root, add=True)
    assert _config(root) == installed

    features.apply_feature(PYTHON, root, root, add=False)
    assert _config(root) == BASE
    assert not features.installed_sites(root, PYTHON)


def test_sync_keeps_root_python_and_its_bumped_revs(
    tmp_path: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(typer, 'prompt', lambda *a, **k: 'value')
    root = _repo(tmp_path)
    features.apply_feature(PYTHON, root, root, add=True)
    config_path = root / template.PRECOMMIT_CONFIG
    config = template.yaml.load(config_path)
    for repo in config['repos']:
        if repo['repo'] == 'https://github.com/astral-sh/ty-pre-commit':
            repo['rev'] = 'v99.0.0'
    template.sync_yaml(config, config_path)
    bumped = _config(root)

    repo_template.sync(root)
    assert _config(root) == bumped
    assert 'rev: v99.0.0' in bumped


def test_root_and_subdir_python_coexist(tmp_path: pathlib.Path) -> None:
    root = _repo(tmp_path)
    features.apply_feature(PYTHON, root, root / 'sub', add=True)
    subdir_only = _config(root)
    # A subdir exclude must not swallow the comment before the next block.
    assert (
        "        exclude: '(^sub/.*)'\n"
        '  # TODO: use ruff once more refurb rules are out of preview\n'
    ) in subdir_only

    features.apply_feature(PYTHON, root, root, add=True)
    both = _config(root)
    assert features.installed_sites(root, PYTHON) == ['.', 'sub']
    config = template.yaml.load(root / template.PRECOMMIT_CONFIG)
    excluded = {
        hook['id']
        for hook in features.iter_hooks(config)
        if hook.get('exclude') == '(^sub/.*)'
    }
    assert excluded == {'flake8', 'pylint', 'ruff-check', 'ruff-format'}

    features.apply_feature(PYTHON, root, root, add=False)
    assert _config(root) == subdir_only

    # Installing in the other order gives the same config.
    features.apply_feature(PYTHON, root, root / 'sub', add=False)
    assert _config(root) == BASE
    features.apply_feature(PYTHON, root, root, add=True)
    features.apply_feature(PYTHON, root, root / 'sub', add=True)
    assert _config(root) == both


def test_placement_still_restricts_root_features(
    tmp_path: pathlib.Path,
) -> None:
    root = _repo(tmp_path)
    features.validate_placement(PYTHON, root, root / 'sub')
    with pytest.raises(typer.BadParameter, match='must target the repo root'):
        features.validate_placement(
            template.Feature.TERRAFORM, root, root / 'sub'
        )

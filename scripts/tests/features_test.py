import pathlib

import pytest
import typer

from dotsystem_scripts import features
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

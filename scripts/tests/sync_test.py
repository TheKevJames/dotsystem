import pathlib

import pytest
import typer
import typer.testing

from dotsystem_scripts import repo_template

SEEDED = '.github/rulesets/required-checks.json'
SYNCED = '.github/workflows/rulesets.yml'


@pytest.fixture(name='source', scope='function')
def source_fixture(
    tmp_path: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> pathlib.Path:
    source = tmp_path / 'config' / 'repo-template'
    for rel, content in {
        'config.toml': f'seeded = ["{SEEDED}"]\n',
        SEEDED: '{"template": true}\n',
        SYNCED: 'name: template\n',
    }.items():
        (source / rel).parent.mkdir(parents=True, exist_ok=True)
        (source / rel).write_text(content)
    monkeypatch.setenv('XDG_CONFIG_HOME', str(tmp_path / 'config'))
    return source


def _sync(target: pathlib.Path) -> None:
    result = typer.testing.CliRunner().invoke(
        repo_template.app, ['sync', str(target)], input='y\n'
    )
    print(result.output)
    assert result.exit_code == 0, result.output


def test_seeded_files_are_created_once_then_left_alone(
    source: pathlib.Path,
    tmp_path: pathlib.Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    target = tmp_path / 'repo'
    target.mkdir()

    _sync(target)
    assert (target / SEEDED).read_text() == (source / SEEDED).read_text()
    assert (target / SYNCED).read_text() == (source / SYNCED).read_text()

    # Target-owned from here: neither a local edit nor a template change is
    # diffed or prompted for, while ordinary files still are.
    (target / SEEDED).write_text('{"repo": true}\n')
    (source / SEEDED).write_text('{"template": "v2"}\n')
    (source / SYNCED).write_text('name: template v2\n')
    prompts: list[str] = []

    def confirm(text: str, *_: object, **__: object) -> bool:
        prompts.append(text)
        return True

    monkeypatch.setattr(typer, 'confirm', confirm)
    _sync(target)

    assert (target / SEEDED).read_text() == '{"repo": true}\n'
    assert (target / SYNCED).read_text() == 'name: template v2\n'
    assert prompts == [f'Overwrite {target / SYNCED}?']

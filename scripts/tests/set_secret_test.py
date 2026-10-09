import json
import pathlib
import re
import sys

import pytest
import typer.testing

from dotsystem_scripts import repo_template

TOKEN = 'github_pat_example'
# Under GITHUB_ACTIONS typer forces rich styling, splitting words like '--yes'.
ANSI = re.compile(r'\x1b\[[0-9;]*m')

# Mirrors the `gh` invocations and output shapes used by `github`; repos named
# `*broken*` reject secrets the way gh does for missing admin access.
FAKE_GH = f"""#!{sys.executable}
import json, os, sys
args = sys.argv[1:]
stdin = '' if sys.stdin.isatty() else sys.stdin.read()
with open(os.environ['GH_LOG'], 'a') as log:
    log.write(json.dumps({{'args': args, 'stdin': stdin}}) + '\\n')
if args[:2] == ['api', 'user']:
    print('someone')
elif args[:2] == ['repo', 'list']:
    print(json.dumps([
        {{'nameWithOwner': 'someone/zeta'}},
        {{'nameWithOwner': 'someone/broken'}},
        {{'nameWithOwner': 'someone/alpha'}},
    ]))
elif args[:2] == ['secret', 'set']:
    if 'broken' in args[args.index('--repo') + 1]:
        print('failed to set secret: HTTP 403', file=sys.stderr)
        sys.exit(1)
else:
    sys.exit(2)
"""


@pytest.fixture(name='gh_log', scope='function')
def gh_log_fixture(
    tmp_path: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> pathlib.Path:
    gh = tmp_path / 'bin' / 'gh'
    gh.parent.mkdir()
    gh.write_text(FAKE_GH)
    gh.chmod(0o755)
    log = tmp_path / 'gh.log'
    monkeypatch.setenv('PATH', str(gh.parent), prepend=':')
    monkeypatch.setenv('GH_LOG', str(log))
    return log


def _calls(log: pathlib.Path) -> list[dict[str, str | list[str]]]:
    if not log.exists():
        return []
    return [json.loads(line) for line in log.read_text().splitlines()]


def test_piped_token_is_set_on_every_public_repo(gh_log: pathlib.Path) -> None:
    runner = typer.testing.CliRunner()

    result = runner.invoke(repo_template.app, ['set-secret'], input=TOKEN)
    print(result.output)
    assert result.exit_code != 0
    assert '--yes is required' in ANSI.sub('', result.output)
    assert not _calls(gh_log)

    result = runner.invoke(
        repo_template.app, ['set-secret', '--yes'], input=f'{TOKEN}\n'
    )
    print(result.output)
    calls = _calls(gh_log)
    print(calls)

    assert result.exit_code == 1
    assert 'FAILED someone/broken: failed to set secret: HTTP 403' in (
        result.output
    )
    sets = [c for c in calls if c['args'][:2] == ['secret', 'set']]
    assert [c['args'][c['args'].index('--repo') + 1] for c in sets] == [
        'someone/alpha',
        'someone/broken',
        'someone/zeta',
    ]
    for call in sets:
        assert call['stdin'] == TOKEN
        assert repo_template.RULESETS_SECRET in call['args']
    assert not any(TOKEN in arg for c in calls for arg in c['args'])

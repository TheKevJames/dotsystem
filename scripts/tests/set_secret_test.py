import json
import pathlib
import re
import subprocess
import sys
import tempfile
from typing import Any

import pytest
import typer
import typer.testing

from dotsystem_scripts import repo_template

TOKEN = 'github_pat_example'
# Under GITHUB_ACTIONS typer forces rich styling, splitting words like '--yes'.
ANSI = re.compile(r'\x1b\[[0-9;]*m')
CUSTOM = {'protected_branches': False, 'custom_branch_policies': True}

# Mirrors the `gh` invocations and output shapes used by `github`, serving
# repos, environments and deploy keys from the JSON state in $GH_STATE.
FAKE_GH = f"""#!{sys.executable}
import json, os, sys
args = sys.argv[1:]
stdin = '' if sys.stdin.isatty() else sys.stdin.read()
with open(os.environ['GH_LOG'], 'a') as log:
    log.write(json.dumps({{'args': args, 'stdin': stdin}}) + '\\n')
with open(os.environ['GH_STATE']) as handle:
    state = json.load(handle)

def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)

def repo_of():
    return state['repos'][args[args.index('--repo') + 1]]

if args[:2] == ['api', 'user']:
    print('someone')
elif args[:2] == ['repo', 'list']:
    print(json.dumps([{{'nameWithOwner': n}} for n in state['repos']]))
elif args[0] == 'api':
    parts = args[1].split('?')[0].split('/')
    repo = state['repos'].get('/'.join(parts[1:3]))
    if repo is None:
        fail('gh: Not Found (HTTP 404)')
    rest = parts[3:]
    if not rest:
        print(json.dumps({{'default_branch': repo['branch']}}))
    elif rest == ['keys']:
        print(json.dumps(repo.get('keys', [])))
    elif rest[0] == 'environments':
        env = repo.get('environments', {{}}).get(rest[1])
        if env is None:
            fail('gh: Not Found (HTTP 404)')
        if len(rest) == 2:
            print(json.dumps({{'deployment_branch_policy': env['policy']}}))
        else:
            print(json.dumps({{'branch_policies': [
                {{'id': i, 'type': t, 'name': n}}
                for i, (t, n) in enumerate(env['policies'])
            ]}}))
    else:
        sys.exit(2)
elif args[:2] == ['secret', 'set']:
    if '--env' not in args:
        fail('repository secrets are not expected here')
    repo_of()
elif args[:2] == ['secret', 'delete']:
    if not repo_of().get('repo_secret'):
        fail('failed to delete secret: HTTP 404: Not Found')
else:
    sys.exit(2)
"""


def _environment(*policies: tuple[str, str]) -> dict[str, Any]:
    return {'policy': CUSTOM, 'policies': list(policies)}


@pytest.fixture(name='gh', scope='function')
def gh_fixture(
    tmp_path: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> pathlib.Path:
    """The fake gh's state file; its call log sits beside it."""
    gh = tmp_path / 'bin' / 'gh'
    gh.parent.mkdir()
    gh.write_text(FAKE_GH)
    gh.chmod(0o755)
    monkeypatch.setenv('PATH', str(gh.parent), prepend=':')
    monkeypatch.setenv('GH_LOG', str(tmp_path / 'gh.log'))
    state = tmp_path / 'state.json'
    monkeypatch.setenv('GH_STATE', str(state))
    return state


def _write(state: pathlib.Path, repos: dict[str, dict[str, Any]]) -> None:
    state.write_text(json.dumps({'repos': repos}))


def _calls(state: pathlib.Path) -> list[dict[str, Any]]:
    log = state.parent / 'gh.log'
    if not log.exists():
        return []
    return [json.loads(line) for line in log.read_text().splitlines()]


def _secret_calls(state: pathlib.Path, verb: str) -> list[dict[str, Any]]:
    return [c for c in _calls(state) if c['args'][:2] == ['secret', verb]]


def _repo(call: dict[str, Any]) -> str:
    args: list[str] = call['args']
    return args[args.index('--repo') + 1]


def _settings_repos() -> dict[str, dict[str, Any]]:
    return {
        'someone/alpha': {
            'branch': 'master',
            'repo_secret': True,
            'environments': {
                'repo-settings': _environment(('branch', 'master'))
            },
        },
        # Created by a workflow run before its definition was applied.
        'someone/beta': {
            'branch': 'master',
            'environments': {'repo-settings': {'policy': None}},
        },
        'someone/missing': {'branch': 'master'},
        # Admits the wrong branch for this repo, and a tag.
        'someone/zeta': {
            'branch': 'main',
            'environments': {
                'repo-settings': _environment(
                    ('branch', 'master'), ('tag', '*')
                )
            },
        },
    }


def test_token_is_only_stored_in_default_branch_only_environments(
    gh: pathlib.Path,
) -> None:
    _write(gh, _settings_repos())
    runner = typer.testing.CliRunner()

    result = runner.invoke(repo_template.app, ['set-secret'], input=TOKEN)
    print(result.output)
    assert result.exit_code != 0
    assert '--yes is required' in ANSI.sub('', result.output)
    assert not _calls(gh)

    result = runner.invoke(
        repo_template.app, ['set-secret', '--yes'], input=f'{TOKEN}\n'
    )
    print(result.output)
    calls = _calls(gh)
    print(calls)
    assert result.exit_code == 1
    for repo in ('beta', 'missing', 'zeta'):
        assert f'FAILED someone/{repo}: environment "repo-settings"' in (
            result.output
        )
    [call] = _secret_calls(gh, 'set')
    assert _repo(call) == 'someone/alpha'
    assert call['args'][call['args'].index('--env') + 1] == 'repo-settings'
    assert call['stdin'] == TOKEN
    assert not _secret_calls(gh, 'delete')
    assert not any(TOKEN in arg for c in calls for arg in c['args'])


def test_prune_deletes_only_replaced_repository_secrets(
    gh: pathlib.Path,
) -> None:
    repos = _settings_repos()
    repos['someone/zeta']['repo_secret'] = True
    repos['someone/gamma'] = repos['someone/alpha'] | {'repo_secret': False}
    _write(gh, repos)

    result = typer.testing.CliRunner().invoke(
        repo_template.app,
        ['set-secret', '--yes', '--prune-repo-secret'],
        input=TOKEN,
    )
    print(result.output)
    assert result.exit_code == 1
    assert 'set, and deleted the repository secret someone/alpha' in (
        result.output
    )
    assert 'set someone/gamma' in result.output
    # zeta's environment is wrong, so its repository secret stays.
    assert [_repo(c) for c in _secret_calls(gh, 'delete')] == [
        'someone/alpha',
        'someone/gamma',
    ]


def _deploy_key(
    gh: pathlib.Path,
    monkeypatch: pytest.MonkeyPatch,
    added: list[dict[str, Any] | None],
) -> typer.testing.Result:
    """
    Run set-deploy-key, the owner adding one of `added` per press of enter.

    Each is a deploy key, its `key` filled in from the generated public key,
    or None for a press before anything was added.
    """
    temp = gh.parent / 'tmp'
    temp.mkdir()
    monkeypatch.setattr(tempfile, 'tempdir', str(temp))
    launched: list[str] = []
    monkeypatch.setattr(typer, 'launch', launched.append)
    original = typer.prompt

    def prompt(*args: Any, **kwargs: Any) -> object:  # noqa: ANN401
        key = added.pop(0)
        if key is not None:
            [public] = temp.glob('*/key.pub')
            state = json.loads(gh.read_text())
            key |= {'key': public.read_text().strip()}
            state['repos']['someone/alpha']['keys'].append(key)
            gh.write_text(json.dumps(state))
        return original(*args, **kwargs)

    monkeypatch.setattr(typer, 'prompt', prompt)
    result = typer.testing.CliRunner().invoke(
        repo_template.app, ['set-deploy-key', 'someone/alpha'], input='\n' * 3
    )
    print(result.output)
    print(_calls(gh))
    assert launched == ['https://github.com/someone/alpha/settings/keys/new']
    assert not list(temp.iterdir())
    return result


def _key_repo(**environments: dict[str, Any]) -> dict[str, dict[str, Any]]:
    old = {'id': 3, 'title': 'tag', 'read_only': False, 'key': 'ssh-x OLD'}
    return {
        'someone/alpha': {
            'branch': 'master',
            'environments': environments,
            'keys': [old],
        }
    }


def test_deploy_key_is_stored_once_added_in_the_web_ui(
    gh: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _write(gh, _key_repo(tag=_environment(('branch', 'master'))))
    result = _deploy_key(
        gh, monkeypatch, [None, {'id': 9, 'title': 'tag', 'read_only': False}]
    )
    assert result.exit_code == 0
    assert 'Not there yet.' in result.output
    [call] = _secret_calls(gh, 'set')
    assert call['args'][call['args'].index('--env') + 1] == 'tag'
    assert 'TAG_DEPLOY_KEY' in call['args']
    # The stored secret is the private half of the key that was added.
    private = gh.parent / 'stored'
    private.write_text(call['stdin'])
    private.chmod(0o600)
    derived = subprocess.run(
        ('ssh-keygen', '-y', '-f', str(private)),
        capture_output=True,
        text=True,
        check=True,
    ).stdout.split()[:2]
    [added] = [
        k
        for k in json.loads(gh.read_text())['repos']['someone/alpha']['keys']
        if k['id'] == 9
    ]
    assert derived == added['key'].split()[:2]
    assert 'Delete the old "tag" key (id 3)' in result.output


def test_deploy_key_needs_a_default_branch_only_environment(
    gh: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _write(gh, _key_repo(tag=_environment(('branch', '*'))))
    monkeypatch.setattr(typer, 'launch', pytest.fail)
    result = typer.testing.CliRunner().invoke(
        repo_template.app, ['set-deploy-key', 'someone/alpha']
    )
    print(result.output)
    assert result.exit_code == 1
    assert 'environment "tag" must exist and admit only master' in (
        result.output
    )
    assert not _secret_calls(gh, 'set')


def test_deploy_key_added_read_only_is_not_stored(
    gh: pathlib.Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _write(gh, _key_repo(tag=_environment(('branch', 'master'))))
    result = _deploy_key(
        gh, monkeypatch, [{'id': 9, 'title': 'tag', 'read_only': True}]
    )
    assert result.exit_code == 1
    assert 'read_only=True: delete it and re-run' in result.output
    assert not _secret_calls(gh, 'set')

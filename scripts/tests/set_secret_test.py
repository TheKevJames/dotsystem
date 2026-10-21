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
# `*broken*` reject environments the way gh does for missing admin access.
# alpha deploys from main and has no environment yet; zeta deploys from master
# and has stale policies, and its repo secret is already gone.
FAKE_GH = f"""#!{sys.executable}
import json, os, sys
args = sys.argv[1:]
stdin = '' if sys.stdin.isatty() else sys.stdin.read()
with open(os.environ['GH_LOG'], 'a') as log:
    log.write(json.dumps({{'args': args, 'stdin': stdin}}) + '\\n')
method = args[args.index('--method') + 1] if '--method' in args else 'GET'
path = next((a for a in args if a.startswith(('repos/', 'user'))), '')
repo = args[args.index('--repo') + 1] if '--repo' in args else (
    '/'.join(path.split('/')[1:3])
)
if path == 'user':
    print('someone')
elif args[:2] == ['repo', 'list']:
    print(json.dumps([
        {{'nameWithOwner': 'someone/zeta'}},
        {{'nameWithOwner': 'someone/broken'}},
        {{'nameWithOwner': 'someone/alpha'}},
    ]))
elif path == f'repos/{{repo}}':
    print('main' if repo.endswith('alpha') else 'master')
elif path.endswith('/environments/repo-settings') and method == 'PUT':
    if 'broken' in repo:
        print('HTTP 403: Must have admin rights', file=sys.stderr)
        sys.exit(1)
    print('{{}}')
elif path.endswith('/deployment-branch-policies') and method == 'GET':
    if repo.endswith('zeta'):
        for policy in [
            {{'id': 1, 'name': 'master', 'type': 'tag'}},
            {{'id': 2, 'name': 'master', 'type': 'branch'}},
            {{'id': 3, 'name': 'feature/*', 'type': 'branch'}},
        ]:
            print(json.dumps(policy))
elif '/deployment-branch-policies' in path and method in ('POST', 'DELETE'):
    print('{{}}')
elif args[:2] == ['secret', 'set']:
    pass
elif args[:2] == ['secret', 'delete']:
    if repo.endswith('zeta'):
        print('HTTP 404: Not Found', file=sys.stderr)
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


def _ops(calls: list[dict[str, str | list[str]]], repo: str) -> list[str]:
    """The calls touching `repo`, as `METHOD path` or `secret <verb>`."""
    ops = []
    for call in calls:
        args = list(call['args'])
        if args[0] == 'secret' and args[args.index('--repo') + 1] == repo:
            ops.append(f'secret {args[1]}')
        elif args[0] == 'api' and any(
            a == f'repos/{repo}' or a.startswith(f'repos/{repo}/')
            for a in args
        ):
            method = (
                args[args.index('--method') + 1]
                if '--method' in args
                else 'GET'
            )
            path = next(a for a in args if a.startswith('repos/'))
            ops.append(f'{method} {path.removeprefix(f"repos/{repo}")}')
    return ops


def _set_secret(*flags: str) -> typer.testing.Result:
    result = typer.testing.CliRunner().invoke(
        repo_template.app, ['set-secret', '--yes', *flags], input=f'{TOKEN}\n'
    )
    print(result.output)
    return result


ENV = '/environments/repo-settings'
POLICIES = f'{ENV}/deployment-branch-policies'


def test_piped_token_is_set_on_every_public_repo(gh_log: pathlib.Path) -> None:
    result = typer.testing.CliRunner().invoke(
        repo_template.app, ['set-secret'], input=TOKEN
    )
    print(result.output)
    assert result.exit_code != 0
    assert '--yes is required' in ANSI.sub('', result.output)
    assert not _calls(gh_log)

    result = _set_secret()
    calls = _calls(gh_log)
    print(calls)

    assert result.exit_code == 1
    assert 'FAILED someone/broken: HTTP 403: Must have admin rights' in (
        result.output
    )
    # The environment and its policy exist before the secret goes in; a repo
    # whose environment fails gets no secret at all.
    assert _ops(calls, 'someone/alpha') == [
        'GET ',
        f'PUT {ENV}',
        f'GET {POLICIES}',
        f'POST {POLICIES}',
        'secret set',
    ]
    assert _ops(calls, 'someone/broken') == ['GET ', f'PUT {ENV}']
    assert _ops(calls, 'someone/zeta') == [
        'GET ',
        f'PUT {ENV}',
        f'GET {POLICIES}',
        f'DELETE {POLICIES}/1',
        f'DELETE {POLICIES}/3',
        'secret set',
    ]
    assert 'set someone/alpha (deploys from main)' in result.output
    assert 'set someone/zeta (deploys from master)' in result.output

    sets = [c for c in calls if c['args'][:2] == ['secret', 'set']]
    assert [c['args'][c['args'].index('--repo') + 1] for c in sets] == [
        'someone/alpha',
        'someone/zeta',
    ]
    for call in sets:
        assert call['stdin'] == TOKEN
        assert call['args'][2] == repo_template.REPO_SETTINGS_SECRET
        env = call['args'][call['args'].index('--env') + 1]
        assert env == repo_template.REPO_SETTINGS_ENVIRONMENT
    assert not any(TOKEN in arg for c in calls for arg in c['args'])


def test_environment_deploys_only_from_the_default_branch(
    gh_log: pathlib.Path,
) -> None:
    _set_secret()
    calls = _calls(gh_log)

    puts = [c for c in calls if '--method' in c['args'] and 'PUT' in c['args']]
    assert len(puts) == 3
    for call in puts:
        assert json.loads(str(call['stdin'])) == {
            'deployment_branch_policy': {
                'protected_branches': False,
                'custom_branch_policies': True,
            }
        }
    posts = [
        c['args']
        for c in calls
        if '--method' in c['args'] and 'POST' in c['args']
    ]
    assert posts == [
        [
            'api',
            '--method',
            'POST',
            f'repos/someone/alpha{POLICIES}',
            '-f',
            'name=main',
            '-f',
            'type=branch',
        ]
    ]


def test_repo_secret_is_pruned_only_on_request(gh_log: pathlib.Path) -> None:
    result = _set_secret('--prune-repo-secret')
    calls = _calls(gh_log)
    print(calls)

    # broken still fails the run; zeta's repo secret was already gone.
    assert result.exit_code == 1
    assert _ops(calls, 'someone/alpha')[-2:] == ['secret set', 'secret delete']
    assert _ops(calls, 'someone/zeta')[-2:] == ['secret set', 'secret delete']
    assert 'secret delete' not in _ops(calls, 'someone/broken')
    for call in calls:
        if call['args'][:2] == ['secret', 'delete']:
            assert call['args'][2] == repo_template.REPO_SETTINGS_SECRET
            assert '--env' not in call['args']
    assert 'set someone/alpha (deploys from main, deleted repo secret)' in (
        result.output
    )
    assert 'set someone/zeta (deploys from master)' in result.output

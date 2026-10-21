"""Thin wrappers over the `gh` CLI, which owns authentication."""

import json
import subprocess


class GhError(RuntimeError):
    pass


def _gh(*args: str, stdin: str | None = None) -> str:
    result = subprocess.run(
        ('gh', *args), input=stdin, capture_output=True, text=True, check=False
    )
    if result.returncode != 0:
        raise GhError(
            result.stderr.strip() or f'gh exited {result.returncode}'
        )
    return result.stdout


def public_repos() -> list[str]:
    """`owner/name` of the user's public, non-archived, non-fork repos."""
    owner = _gh('api', 'user', '--jq', '.login').strip()
    output = _gh(
        'repo',
        'list',
        owner,
        '--visibility',
        'public',
        '--no-archived',
        '--source',
        '--limit',
        '1000',
        '--json',
        'nameWithOwner',
    )
    return sorted(repo['nameWithOwner'] for repo in json.loads(output))


def default_branch(repo: str) -> str:
    return _gh('api', f'repos/{repo}', '--jq', '.default_branch').strip()


def ensure_environment(repo: str, name: str, branch: str) -> None:
    """
    Create or update environment `name`, deployable only from `branch`.

    Its custom deployment branch policies end up as exactly one: `branch`.
    """
    env = f'repos/{repo}/environments/{name}'
    body = {
        'deployment_branch_policy': {
            'protected_branches': False,
            'custom_branch_policies': True,
        }
    }
    _gh('api', '--method', 'PUT', env, '--input', '-', stdin=json.dumps(body))

    policies = f'{env}/deployment-branch-policies'
    output = _gh('api', '--paginate', policies, '--jq', '.branch_policies[]')
    found = False
    for policy in (json.loads(line) for line in output.splitlines() if line):
        # Branch policies predating tag policies have no `type`.
        is_branch = policy.get('type', 'branch') == 'branch'
        if is_branch and policy['name'] == branch:
            found = True
        else:
            _gh('api', '--method', 'DELETE', f'{policies}/{policy["id"]}')
    if not found:
        _gh(
            'api',
            '--method',
            'POST',
            policies,
            '-f',
            f'name={branch}',
            '-f',
            'type=branch',
        )


def set_environment_secret(
    repo: str, environment: str, name: str, value: str
) -> None:
    # Passed on stdin: as an argument the value would be visible in `ps`.
    # Environment secrets are Actions-only, so there is no `--app`.
    _gh(
        'secret',
        'set',
        name,
        '--env',
        environment,
        '--repo',
        repo,
        stdin=value,
    )


def delete_actions_secret(repo: str, name: str) -> bool:
    """Delete a repository secret; False if it was already absent."""
    try:
        _gh('secret', 'delete', name, '--app', 'actions', '--repo', repo)
    except GhError as exc:
        if 'HTTP 404' in str(exc):
            return False
        raise
    return True

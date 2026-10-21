"""Thin wrappers over the `gh` CLI, which owns authentication."""

import json
import subprocess
from typing import Any


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


def _api(path: str) -> Any:  # noqa: ANN401
    return json.loads(_gh('api', path))


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
    branch: str = _api(f'repos/{repo}')['default_branch']
    return branch


def environment_policies(
    repo: str, environment: str
) -> frozenset[tuple[str, str]] | None:
    """
    The (type, pattern) refs that may use `environment`.

    None if it doesn't exist or isn't restricted to named refs.
    """
    try:
        env = _api(f'repos/{repo}/environments/{environment}')
    except GhError as exc:
        if 'HTTP 404' in str(exc):
            return None
        raise
    if env['deployment_branch_policy'] != {
        'protected_branches': False,
        'custom_branch_policies': True,
    }:
        return None
    policies = _api(
        f'repos/{repo}/environments/{environment}/deployment-branch-policies'
        '?per_page=100'
    )
    found: frozenset[tuple[str, str]] = frozenset(
        (policy.get('type', 'branch'), policy['name'])
        for policy in policies['branch_policies']
    )
    return found


def set_actions_secret(
    repo: str, name: str, value: str, environment: str | None = None
) -> None:
    """A repository secret, or an environment secret with `environment`."""
    scope = ('--env', environment) if environment else ('--app', 'actions')
    # Passed on stdin: as an argument the value would be visible in `ps`.
    _gh('secret', 'set', name, *scope, '--repo', repo, stdin=value)


def delete_actions_secret(repo: str, name: str) -> bool:
    """Delete a repository secret; False if there was none."""
    try:
        _gh('secret', 'delete', name, '--app', 'actions', '--repo', repo)
    except GhError as exc:
        if 'HTTP 404' in str(exc):
            return False
        raise
    return True


def deploy_keys(repo: str) -> list[dict[str, Any]]:
    keys: list[dict[str, Any]] = _api(f'repos/{repo}/keys?per_page=100')
    return keys

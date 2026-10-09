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


def set_actions_secret(repo: str, name: str, value: str) -> None:
    # Passed on stdin: as an argument the value would be visible in `ps`.
    _gh('secret', 'set', name, '--app', 'actions', '--repo', repo, stdin=value)

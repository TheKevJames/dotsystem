"""
The credentials templated workflows depend on, which only the owner can set.

Both live in environments that only the default branch may use (defined in
the repo's `.github/environments/` and created by the repo-settings
workflow), so a collaborator's branch can't read them. They refuse to store a
credential anywhere else.
"""

import pathlib
import subprocess
import sys
import tempfile
from typing import Annotated
from typing import Any

import typer

from . import github

# Consumed by TheKevJames/tools/.github/workflows/_repo-settings.yml.
REPO_SETTINGS_SECRET = 'REPO_SETTINGS_TOKEN'
REPO_SETTINGS_ENVIRONMENT = 'repo-settings'
# Consumed by TheKevJames/tools/.github/workflows/_tag.yml; the title is the
# only write deploy key its repo-settings deploy_keys check allows.
TAG_SECRET = 'TAG_DEPLOY_KEY'
TAG_ENVIRONMENT = 'tag'
TAG_KEY_TITLE = 'tag'


def require_default_branch_only(repo: str, environment: str) -> None:
    branch = github.default_branch(repo)
    policies = github.environment_policies(repo, environment)
    if policies != {('branch', branch)}:
        raise github.GhError(
            f'environment "{environment}" must exist and admit only '
            f'{branch} (has {sorted(policies) if policies else "none"}); '
            'define it in .github/environments/ and let the repo-settings '
            'workflow apply it'
        )


def read_token(piped: bool) -> str:
    if piped:
        token = typer.get_text_stream('stdin').read()
    else:
        # typer.prompt returns Any; it is a str without a `type=` converter.
        token = str(
            typer.prompt(
                'Fine-grained PAT (Administration: write)', hide_input=True
            )
        )
    token = token.strip()
    if not token:
        raise typer.BadParameter('token is empty')
    return token


def _set_repo_settings_token(repo: str, token: str, prune: bool) -> str:
    require_default_branch_only(repo, REPO_SETTINGS_ENVIRONMENT)
    github.set_actions_secret(
        repo, REPO_SETTINGS_SECRET, token, REPO_SETTINGS_ENVIRONMENT
    )
    if prune and github.delete_actions_secret(repo, REPO_SETTINGS_SECRET):
        return 'set, and deleted the repository secret'
    return 'set'


def set_secret(
    yes: Annotated[
        bool, typer.Option('--yes', '-y', help='skip the confirmation')
    ] = False,
    prune_repo_secret: Annotated[
        bool,
        typer.Option(
            help='also delete the repository-level secret it replaces'
        ),
    ] = False,
) -> None:
    """
    Set the repo settings admin token on every public repo.

    It is stored in each repo's `repo-settings` environment, which must
    already admit only the default branch. Reads the token from a hidden
    prompt, or from stdin when piped (which requires --yes). Re-run to rotate
    it.
    """
    piped = not sys.stdin.isatty()
    if piped and not yes:
        raise typer.BadParameter('--yes is required when piping the token')

    repos = github.public_repos()
    typer.echo('\n'.join(repos))
    if not yes:
        typer.confirm(
            f'Set {REPO_SETTINGS_SECRET} on these {len(repos)} repos?',
            abort=True,
        )

    token = read_token(piped)
    failures = 0
    for repo in repos:
        try:
            outcome = _set_repo_settings_token(repo, token, prune_repo_secret)
        except github.GhError as exc:
            failures += 1
            typer.echo(f'FAILED {repo}: {exc}', err=True)
        else:
            typer.echo(f'{outcome} {repo}')
    if failures:
        raise typer.Exit(1)


def _generate_key(directory: pathlib.Path, repo: str) -> pathlib.Path:
    path = directory / 'key'
    subprocess.run(
        (
            'ssh-keygen',
            '-q',
            '-t',
            'ed25519',
            '-N',
            '',
            '-C',
            f'{TAG_KEY_TITLE}@{repo}',
            '-f',
            str(path),
        ),
        check=True,
    )
    return path


def _added(repo: str, public: str) -> dict[str, Any] | None:
    """The deploy key holding `public`, once the owner has added it."""
    material = public.split()[:2]
    for key in github.deploy_keys(repo):
        if str(key['key']).split()[:2] == material:
            return key
    return None


def _wait_for_key(repo: str, public: str) -> None:
    url = f'https://github.com/{repo}/settings/keys/new'
    typer.echo(
        f'\nAdd this deploy key at {url}\n'
        f'  Title: {TAG_KEY_TITLE}\n'
        f'  Key:   {public}\n'
        '  Allow write access: yes\n'
        'It has to be added in the web UI: a key added through the API is '
        'deleted along with the token that added it.\n'
    )
    typer.launch(url)
    while True:
        typer.prompt(
            'Press enter once it is added', default='', show_default=False
        )
        key = _added(repo, public)
        if key is None:
            typer.echo('Not there yet.')
        elif key['read_only'] or key['title'] != TAG_KEY_TITLE:
            raise github.GhError(
                f'the key was added as "{key["title"]}" with '
                f'read_only={key["read_only"]}: delete it and re-run'
            )
        else:
            return


def set_deploy_key(
    repo: Annotated[str, typer.Argument(help='owner/name')],
) -> None:
    """
    Give a repo the deploy key its release tags are pushed with.

    Generates a key, waits while you add its public half in the web UI, then
    stores the private half as the `tag` environment's TAG_DEPLOY_KEY. The
    `tag` environment must already admit only the default branch. Re-run to
    rotate it, then delete the old key in the web UI.
    """
    try:
        require_default_branch_only(repo, TAG_ENVIRONMENT)
        with tempfile.TemporaryDirectory() as directory:
            path = _generate_key(pathlib.Path(directory), repo)
            public = path.with_suffix('.pub').read_text().strip()
            _wait_for_key(repo, public)
            github.set_actions_secret(
                repo, TAG_SECRET, path.read_text(), TAG_ENVIRONMENT
            )
    except github.GhError as exc:
        typer.echo(f'FAILED {repo}: {exc}', err=True)
        raise typer.Exit(1) from exc
    others = [
        key
        for key in github.deploy_keys(repo)
        if key['title'] == TAG_KEY_TITLE
        and str(key['key']).split()[:2] != public.split()[:2]
    ]
    typer.echo(f'set {repo}')
    for key in others:
        typer.echo(
            f'Delete the old "{TAG_KEY_TITLE}" key (id {key["id"]}) at '
            f'https://github.com/{repo}/settings/keys'
        )

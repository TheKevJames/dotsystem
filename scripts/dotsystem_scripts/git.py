"""Run git subcommands in a directory and capture stripped stdout."""

import pathlib
import subprocess


def run_git(cwd: pathlib.Path, *args: str) -> str | None:
    """Return stripped stdout, or None if git exits non-zero."""
    result = subprocess.run(
        ('git', '-C', str(cwd), *args),
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()

"""Resolve base directories from environment variables with home fallbacks."""

import os
import pathlib


def resolve_base(
    env_var: str, fallback: pathlib.Path, *subpath: str
) -> pathlib.Path:
    """Env var (if set) else `fallback` as the base, joined with `subpath`."""
    value = os.getenv(env_var, '').strip()
    base = pathlib.Path(value) if value else fallback
    return base.joinpath(*subpath).resolve()

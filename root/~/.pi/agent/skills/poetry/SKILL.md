---
name: poetry
description: Reference for Poetry workflows including dependency management, lockfile maintenance, and test execution. Use when working with Python projects that use Poetry (poetry.lock present).
---

# Poetry

## Critical Rule
**After modifying `pyproject.toml`, always run `poetry lock` in that directory** to update the lockfile. Failing to do this will cause CI failures and inconsistent environments.

```bash
cd /path/to/project
poetry lock
```

If multiple `pyproject.toml` files were modified (e.g., in a monorepo), run `poetry lock` in **each** directory.

## Dependency Management

### Add a dependency
```bash
poetry add "package-name>=1.0,<2.0"
```

Never add a dependency without specifying a version binding.

### Add a dev dependency
```bash
poetry add --group dev package-name
```

### Remove a dependency
```bash
poetry remove package-name
```

### Update dependencies
```bash
poetry update           # Update all
poetry update package   # Update specific package
poetry lock             # Regenerate lockfile without installing
```

## Running Commands

### Run tests
```bash
poetry run pytest
poetry run pytest tests/specific_test.py
```

### Run any command in the venv
```bash
poetry run python -m mymodule
poetry run mypy .
poetry run flake8 .
```

### Activate the shell
```bash
poetry shell
```

## pyproject.toml Standards

### Modern Python standards (preferred)
Use standard Python fields where possible instead of Poetry-specific ones:

```toml
[project]
name = "my-package"
version = "1.0.0"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.28",
]

[dependency-groups]
dev = [
    "pytest>=7.0",
    "mypy>=1.0",
]

[tool.poetry]
# Only use for Poetry-specific config (sources, scripts, etc.)
```

### Poetry-specific fields
Keep only what requires Poetry-specific handling:
```toml
[tool.poetry.dependencies]
# Source-specific overrides
torch = { version = ">=2.0", source = "pytorch" }

[[tool.poetry.source]]
name = "pytorch"
url = "https://download.pytorch.org/whl/cpu"
priority = "explicit"
```

## Validation

### Check lockfile consistency
```bash
poetry check
poetry lock --check  # Verify lockfile matches pyproject.toml
```

### Pre-commit integration
Many projects validate `pyproject.toml` via pre-commit:
```bash
pre-commit run -a
```

## Tips
- Never use `pip install` directly — use `poetry add` for dependencies
- When migrating Poetry-specific fields to standard Python fields, always run `poetry lock` after
- If `poetry lock` fails, check for conflicting version constraints
- Use `poetry show --tree` to debug dependency resolution issues
- The `poetry.lock` file should always be committed to version control

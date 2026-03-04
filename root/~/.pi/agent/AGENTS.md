# Project Guidelines
## Code Style
- Follow existing project conventions
- Use meaningful variable names
- Keep functions under 50 lines
- Add comments for complex logic only
- Prefer importing modules instead of classes or functions, unless you are importing from `typing` or `collections.abc`
- Only rename imports (using `as`) when required to solve naming collisions

## Git
- Conventional Commits: feat/fix/refactor/docs/test/chore
- Atomic commits, one concern per commit
- Never force push to main or master

## Safety
- Never hardcode secrets or API keys
- Always validate user input
- Handle errors explicitly, no silent failures

## Workflow
- Read before write — understand context first
- Minimal changes — don't refactor unrelated code
- Verify after changes — run tests or check output
- Ask before chosing a new approach - do not assume my preferences
- Do not install packages or configure my environment - ask me if you think you need to do this
- If you ever run into issues where you think the environment is not set up properly, for example where you can't run tests, can't import a library from my codebase, can't run an interpreter, etc, ask me how to proceed.
- Use `pre-commit run -a` after any changes to validate
- Never remove `TODO` comments without asking me, unless you are solving that particular TODO

## File Access
- Never read files in the following folders unless explicitly necessary: `.mypy_cache`, `.pytest_cache`, `__pycache__`.

### CSS and JavaScript
- Prefer CSS over JavaScript when both can effectively solve a rendering issue

### Python
Never use ``pip`` or ``pip install`` directly.

- System tools should be managed with ``pipx``
- Prefer `poetry` for managing python projects
- Only use `uv` if a project contains a `uv.lock` file and does not contain a `poetry.lock` file

# System Features
You have access to the following additional shell tools that will help you find and discover things:

```
difftastic (command: difft)
eb
fd-find (command: fd)
gh
hyperfine
jira-cli (command: jira)
jq
miller (command: mlr)
ngrok
pre-commit
ripgrep (command: rg)
shellcheck
yq
```

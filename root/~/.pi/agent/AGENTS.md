# Project Guidelines
## Code Style
- Follow existing project conventions
- Use meaningful variable names
- Keep functions under 50 lines
- Add comments for complex logic only
- Prefer importing modules instead of classes or functions, unless you are importing from `typing` or `collections.abc`
- Only rename imports (using `as`) when required to solve naming collisions
- Before implementing a feature as a special case, ask: "is this actually the general rule applied to a new domain?" If yes, implement the general rule and remove the special case, even if it's more work

## Git
- Conventional Commits: feat/fix/refactor/docs/test/chore
- Atomic commits, one concern per commit
- Never force push
- Prefix branch names with "kjames/"

## Safety
- Never hardcode secrets or API keys
- Always validate user input
- Handle errors explicitly, no silent failures

## Workflow
- Read before write — understand context first
- Minimal changes — don't refactor unrelated code
- Verify after changes — run tests or check output
- Ask before chosing a new approach - do not assume my preferences
- Do not install packages globally or configure my environment - ask me if you think you need to do this. You may make use of and install to local, git-controlled environments, such as running `poetry sync` and using the associated venv
- If you ever run into issues where you think the environment is not set up properly, for example where you can't run tests, can't import a library from my codebase, can't run an interpreter, etc, ask me how to proceed
- Use `pre-commit run -a` after any changes to validate
- Never remove `TODO` comments without asking me, unless you are solving that particular TODO
- Never say 'applied/implemented/done' unless you can immediately cite: (a) tool output confirming the edit, and (b) git diff (or re-read of the edited block)
- When a task can be solved with a built-in feature of the tool/framework, prefer that over custom workarounds
- Search docs before building regex/scripting solutions
- Do not fabricate theories or assume system state — verify with actual data before proposing root causes
- When you don't know something about a tool's API, read its documentation first rather than guessing and iterating
- When asked to fix X, apply the minimal targeted fix — do not broaden scope without asking
- Transient / flaky test failures should always be marked for investigation - do not interrupt your current work, but suggest it for immediate follow-up once you're done
- Update docs, TODOs, diagrams, etc after changing anything they refer to

## File Access
- Never read files in the following folders unless explicitly necessary: `.mypy_cache`, `.pytest_cache`, `__pycache__`.

## Specific File/Application Types
### CSS and JavaScript
- Prefer CSS over JavaScript when both can effectively solve a rendering issue
- After every CSS file edit, re-read the modified block to verify the rules are actually present
- Before implementing any UI component (tooltip, badge, modal, dropdown, etc.), search for an existing instance of the same component type in the codebase and replicate its implementation exactly. Never reach for a browser native (e.g. title=, <details>) if a custom pattern already exists.

### Python
Never use ``pip`` or ``pip install`` directly.

- System tools should be managed with ``pipx``
- Prefer `poetry` for managing python projects
- Only use `uv` if a project contains a `uv.lock` file and does not contain a `poetry.lock` file
- Prefer modern APIs (such as `pathlib`) over deprecated/older alternatives (eg. `os`)
- Prefer typed locals over cast for solving upstream typehint issues

### Redis
Refer to `https://redis.antirez.com/` when working with redis.

# System Features
You have access to the following additional shell tools that will help you find and discover things:

```
ast-grep (command: sg)
difftastic (command: difft)
eb
entr
fd-find (command: fd)
gh
gog
hyperfine
jira-cli (command: jira)
jq
miller (command: mlr)
ngrok
pre-commit
ripgrep (command: rg)
shellcheck
sqlite3
yq
```

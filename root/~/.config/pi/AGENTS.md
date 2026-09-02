# Project Guidelines
## Code Style
- Follow existing project conventions
- Use meaningful variable names
- Keep functions under ~50 lines
- Only rename imports (using `as`) when required to solve naming collisions
- Before implementing a feature as a special case, ask: "is this actually the general rule applied to a new domain?" If yes, implement the general rule and remove the special case, even if it's more work
- Helper scripts should live in "bin/"
- Prevent bad data from entering the system, don't program defenses against that bad data in each function

### Comments
- Only add comments where they will be useful as additional context for future people reading the code
- Do not re-state what the code does or explain why it was added (use the git commit message for this)
- Explain complicated gotchas and non-obvious reasons why the code should not changed
- Assume your audience is experienced and high-level engineers
- Do not refer to previous versions, eg. never add a comment stating how the code was before your change

## Git
- Conventional Commits: feat/fix/refactor/docs/test/chore
- Use message files for writing commit messages and PR bodies
- Commit body suffix should always be "Closes #xxx" when that commit resolves an issue on our issue tracker
- Never force-push to master/main -- force-pushing to a branch is OK, as is pushing to master/main
- Naming: when creating branches, prefix them with "kjames/"
- Use stacked PRs where appropriate

## Workflow
- Read before write — understand context first. Re-read the exact target region immediately before an `edit`, especially for a file you edited earlier this session
- Minimal changes — don't refactor unrelated code
- Verify after changes — run linters, tests, and check output
- Ask before chosing a new approach - do not assume my preferences
- Do not install packages globally or configure my environment - ask me if you think you need to do this. You may make use of and install to local, git-controlled environments, such as running `poetry sync` and using the associated venv
- If you ever run into issues where you think the environment is not set up properly, for example where you can't run tests, can't import a library from my codebase, can't run an interpreter, etc, ask me how to proceed
- Never remove `TODO` comments without asking me, unless you are solving that particular TODO
- Never say 'applied/implemented/done' unless you can immediately cite: (a) tool output confirming the edit, and (b) git diff (or re-read of the edited block)
- When a task can be solved with a built-in feature of the tool/framework, prefer that over custom workarounds
- Search docs before building regex/scripting solutions
- Do not fabricate theories or assume system state — verify with actual data before proposing root causes
- When you don't know something about a tool's API, read its documentation first rather than guessing and iterating
- When asked to fix X, apply the minimal targeted fix — do not broaden scope without asking
- Transient / flaky test failures should always be marked for investigation - do not interrupt your current work, but suggest it for immediate follow-up once you're done
- Update docs, TODOs, diagrams, changelogs, etc after changing anything they refer to
- For independent read-only investigation across multiple repos/services, fan out with parallel subagents before implementing

## Tool Use
- Use the bash tool's `timeout` parameter when useful
- Read targeted ranges of files using the read tool with `offset` and `limit`
- For multi-line file content or scripts, use the `write` tool (or a `bin/` helper), not `cat <<EOF` / `echo` with embedded quotes

## Testing and Linting
- use `prek` for linting and static analysis
- avoid unit tests which test the implementation rather than the interface
- prefer property testing approaches and tools like `hypothesis`
- running the full test harness must be fast -- consolidate tests, reduce test scope for capturing precise issues, avoid low-value tests
- transient and flaky tests must be identified for later follow-up
- do not disable tests or linters without confirmation, fix the issue instead

## File Access
- Never read files in the following folders unless explicitly necessary: `.mypy_cache`, `.pytest_cache`, `__pycache__`.

## Specific File/Application Types
### CSS and JavaScript
- Prefer CSS over JavaScript when both can effectively solve a rendering issue
- After every CSS file edit, re-read the modified block to verify the rules are actually present
- Before implementing any UI component (tooltip, badge, modal, dropdown, etc.), search for an existing instance of the same component type in the codebase and replicate its implementation exactly. Never reach for a browser native (e.g. title=, <details>) if a custom pattern already exists.

### Python
- Bare `python` is not installed, use `python3` or the poetry venv
- Never use `pip` or `pip install` directly
- System tools should be managed with `pipx`
- Prefer `poetry` for managing python projects
- Only use `uv` if a project contains a `uv.lock` file and does not contain a `poetry.lock` file
- Prefer modern APIs (such as `pathlib`) over deprecated/older alternatives (eg. `os`)
- Prefer typed locals over cast for solving upstream typehint issues
- Prefer importing modules instead of classes or functions, unless you are importing from `typing` or `collections.abc`

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
gron
grpcurl
hyperfine
jira-cli (command: jira)
jq
kubectl mtail
kubectl stern
miller (command: mlr)
ngrok
prek
ripgrep (command: rg)
shellcheck
sqlite3
yq
```

## Docs-First Principle

Before implementing a workaround, building a regex hack, or guessing at tool/framework API behavior:

1. **Search documentation first.** Use the context7 skill or read official docs to check whether a built-in feature already solves the problem.
2. **Verify assumptions.** Do not assume system state, API limits, or framework behavior - look it up or test it. If you cannot verify, say so explicitly rather than guessing.
3. **Prefer built-in features.** If a framework provides a purpose-built solution (eg. stage.truncate, lifecycle ignore_changes), always prefer it over custom workarounds.
4. **Admit uncertainty.** When you don't know something, say "I'm not sure — let me check" rather than confidently stating something that might be wrong.

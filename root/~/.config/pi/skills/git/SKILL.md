---
name: git
description: Git-related skillset, use whenever you're working with git or Github.
---

# Git

Help with Git operations and best practices.

## CLI Best Practices

* Prefer `gh` commands over raw `git` commands for GitHub-specific operations (issues, PRs, releases)
* Use `gh repo view` to quickly inspect repository details
* Use `gh pr checkout NUMBER` to checkout the branch corresponding to a given PR number
* Check `gh --help` for discovering subcommands and capabilities

## Commit Messages
Follow Conventional Commits:
```
feat(scope): add new feature
fix(scope): fix bug description
refactor(scope): restructure code
docs(scope): update documentation
test(scope): add/update tests
chore(scope): maintenance tasks
```

## Conflict Resolution
1. `git diff --name-only --diff-filter=U` — Find conflicted files
2. Read each conflicted file
3. Understand both sides of the conflict
4. Resolve with minimal changes preserving intent from both sides

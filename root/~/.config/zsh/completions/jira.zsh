# shellcheck shell=bash
if which jira >/dev/null; then
    # TODO: not zsh??
    eval "$(jira --completion-script-bash)"
fi

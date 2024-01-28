# shellcheck shell=bash
if type -p jira >/dev/null; then
    # TODO: not zsh??
    eval "$(jira --completion-script-bash)"
fi

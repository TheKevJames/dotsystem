# shellcheck shell=bash source=/dev/null
if type -p jira >/dev/null; then
    eval "$(jira completion zsh)"
fi

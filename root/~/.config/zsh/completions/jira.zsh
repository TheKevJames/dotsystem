# shellcheck shell=bash
if type -p jira >/dev/null; then
    eval "$(jira --completion-script-bash)"
fi

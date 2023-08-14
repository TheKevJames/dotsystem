# shellcheck shell=bash
if which jira >/dev/null; then
    eval "$(jira --completion-script-bash)"
fi

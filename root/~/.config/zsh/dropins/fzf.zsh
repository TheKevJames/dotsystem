# shellcheck shell=bash
export FZF_DEFAULT_COMMAND='fd -u --type f'
export FZF_DEFAULT_OPTS='--height 40% --border --bind="ctrl-o:become(nvim {+})"'
export PATH="${XDG_DATA_HOME}/nvim/lazy/fzf/bin:${PATH}"

# fzf a file and open it:
# * CTRL-O to open with `open` command,
# * CTRL-E or Enter key to open with the $EDITOR
# Based on:
# https://github.com/junegunn/fzf/wiki/Examples#opening-files
fzfopen() {
    read -rd '\n' key file <<<"$(fzf-tmux -- --query="${1:-.}" --exit-0 --expect=ctrl-e,ctrl-o)"
    if [ -n "${key}" ]; then
        if [ "${key}" = "ctrl-o" ]; then
            open "${file}"
        else
            "${EDITOR:-vim}" "${file:-${key}}"
        fi
    fi
}

# fzf a process and kill it
# Based on:
# https://github.com/junegunn/fzf/wiki/Examples#processes
fzfkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ "$pid" != "" ]; then
        echo "${pid}" | xargs kill -"${1:-9}"
    fi
}

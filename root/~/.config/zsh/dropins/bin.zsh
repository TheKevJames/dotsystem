# shellcheck shell=bash
# Sync cwd across shells
# Stolen from:
# https://github.com/statico/dotfiles/blob/31899c42000219a8b4dbd2b4857af5cb98b38358/.zshrc#L378-L386
tmpdir="${TMPDIR:-/tmp}"
pin() {
    rm -f "${tmpdir}/pindir"
    (umask 0177; echo "${PWD}" >"${tmpdir}/pindir")
}
pout() {
    cd "$(cat "${tmpdir}/pindir")" || return
}

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

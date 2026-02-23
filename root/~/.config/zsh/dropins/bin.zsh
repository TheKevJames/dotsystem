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

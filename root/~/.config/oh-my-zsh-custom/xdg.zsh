export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export HELM_HOME="${XDG_CACHE_HOME}/helm"
export ICEAUTHORITY="${XDG_RUNTIME_DIR}/ICEauthority"  # NOTE: also must be set in /etc/environment
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"
export IRBRC="/etc/irbrc"
export JULIA_HISTORY="${XDG_DATA_HOME}/julia/history"
export JULIA_PKGDIR="${XDG_DATA_HOME}/julia"
export LESSHISTFILE="${XDG_DATA_HOME}/less/history"
export MYSQL_HISTFILE="${XDG_DATA_HOME}/mysql/history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/config"
export PSQLRC="${XDG_CONFIG_HOME}/psqlrc"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PYLINTHOME="${XDG_DATA_HOME}/pylint"
export PYTHONSTARTUP="/etc/pythonstart"
export REDISCLI_HISTFILE="${XDG_DATA_HOME}/redis/history"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export WINEPREFIX="${XDG_DATA_HOME}/wine/prefixes/default"

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias tmux='tmux -f /etc/tmux.conf'
    # TODO: multi-path ./sync
    cp -r "${HOME}/.config/sublime-text-3/Packages/User/"* "${HOME}/Library/Application Support/Sublime Text 3/Packages/User"
fi

ngrok() {
    if echo "authtoken http start tcp tls" | grep -w "${1:-DEFAULT}" >/dev/null; then
        if [[ "$@" != *"--config"* ]]; then
            command ngrok "$1" --config "${XDG_CONFIG_HOME}/ngrok.yml" "${@:2}"
            return $?
        fi
    fi

    command ngrok "$@"
}

sqlite3() {
    rm -f ~/.sqlite_history && ln -s "${XDG_DATA_HOME}/sqlite/history" ~/.sqlite_history

    command sqlite3 -init "${XDG_CONFIG_HOME}/sqlite" "$@"
    (cd; rm .sqlite_history)
}

alias arc="arc --arcrc-file ${XDG_DATA_HOME}/arc/rc"
alias cpan="cpan -j ${XDG_CONFIG_HOME}/cpan/Config.pm"
alias irssi="irssi --home=${XDG_CONFIG_HOME}/irssi"

export PATH="${PYENV_ROOT}/shims:${CARGO_HOME}/bin:${PATH}"

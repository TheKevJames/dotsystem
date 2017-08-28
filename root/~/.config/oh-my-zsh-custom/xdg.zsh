export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export ICEAUTHORITY="${XDG_RUNTIME_DIR}/ICEauthority"  # NOTE: also must be set in /etc/environment
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"
export IRBRC="/etc/irbrc"
export LESSHISTFILE="${XDG_DATA_HOME}/less/history"
export MYSQL_HISTFILE="${XDG_DATA_HOME}/mysql/history"
export PSQLRC="${XDG_CONFIG_HOME}/psqlrc"
export PYTHONSTARTUP="/etc/pythonstart"
export REDISCLI_HISTFILE="${XDG_DATA_HOME}/redis/history"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export WINEPREFIX="${XDG_DATA_HOME}/wine/prefixes/default"

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

alias cpan="cpan -j ${XDG_CONFIG_HOME}/cpan/Config.pm"
alias irssi="irssi --home=${XDG_CONFIG_HOME}/irssi"

export PATH="${XDG_DATA_HOME}/cargo/bin:${PATH}"

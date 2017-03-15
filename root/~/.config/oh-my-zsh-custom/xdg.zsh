export IRBRC=/etc/irbrc
export LESSHISTFILE=${XDG_DATA_HOME}/less/history
export MYSQL_HISTFILE=${XDG_DATA_HOME}/mysql/history
export PSQLRC=${XDG_CONFIG_HOME}/psqlrc
export PYTHONSTARTUP=/etc/pythonstart
export REDISCLI_HISTFILE=${XDG_DATA_HOME}/redis/history

ngrok() {
    if echo "authtoken http start tcp tls" | grep -w "${1:-DEFAULT}" >/dev/null; then
        if [[ "$@" != *"--config"* ]]; then
            command ngrok "$1" --config ${XDG_CONFIG_HOME}/ngrok.yml "${@:2}"
            return $?
        fi
    fi

    command ngrok "$@"
}

sqlite3() {
    mkdir -p ${XDG_DATA_HOME}/sqlite

    rm -f ~/.sqliterc && ln -s ${XDG_CONFIG_HOME}/sqlite ~/.sqliterc
    rm -f ~/.sqlite_history && ln -s ${XDG_DATA_HOME}/sqlite/history ~/.sqlite_history

    command sqlite3 "$@"
    (cd; rm .sqliterc .sqlite_history)
}

alias irssi="irssi --home=${XDG_CONFIG_HOME}/irssi"

export IRBRC=/etc/irbrc
export LESSHISTFILE=${XDG_DATA_HOME}/less/history
export MYSQL_HISTFILE=${XDG_DATA_HOME}/mysql/history
export PSQLRC=${XDG_CONFIG_HOME}/psqlrc
export REDISCLI_HISTFILE=${XDG_DATA_HOME}/redis/history

sqlite3() {
    mkdir -p ${XDG_DATA_HOME}/sqlite

    rm -f ~/.sqliterc && ln -s ${XDG_CONFIG_HOME}/sqlite ~/.sqliterc
    rm -f ~/.sqlite_history && ln -s ${XDG_DATA_HOME}/sqlite/history ~/.sqlite_history

    command sqlite3 "$@"
    (cd; rm .sqliterc .sqlite_history)
}

# shellcheck shell=bash
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export ICEAUTHORITY="${XDG_RUNTIME_DIR}/ICEauthority"  # NOTE: also must be set in /etc/environment
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"
export LESSHISTFILE="${XDG_DATA_HOME}/less/history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/config"
export PSQLRC="${XDG_CONFIG_HOME}/psqlrc"
export PYLINTHOME="${XDG_DATA_HOME}/pylint"
export PYTHONSTARTUP="/etc/pythonstart"
export REDISCLI_HISTFILE="${XDG_DATA_HOME}/redis/history"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/rg/ignore"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite/history"

alias wget='wget --hsts-file ${XDG_DATA_HOME}/wget/hsts'

export PATH="${XDG_SRC_HOME}/google-cloud-sdk/bin:${CARGO_HOME}/bin:${PATH}"

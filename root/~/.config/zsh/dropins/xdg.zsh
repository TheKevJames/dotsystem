export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep"
export ALACRITTY_LOG="${XDG_DATA_HOME}/alacritty/history"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"
export GOPATH="${XDG_DATA_HOME}/go"
export HELM_HOME="${XDG_CACHE_HOME}/helm"
export ICEAUTHORITY="${XDG_RUNTIME_DIR}/ICEauthority"  # NOTE: also must be set in /etc/environment
export INPUTRC="${XDG_CONFIG_HOME}/inputrc"
export IRBRC="/etc/irbrc"
export JULIA_HISTORY="${XDG_DATA_HOME}/julia/history"
export JULIA_PKGDIR="${XDG_DATA_HOME}/julia"
export KREW_ROOT="${XDG_DATA_HOME}/krew"
export KUBECONFIG="${XDG_CONFIG_HOME}/kube"
export LESSHISTFILE="${XDG_DATA_HOME}/less/history"
export MYSQL_HISTFILE="${XDG_DATA_HOME}/mysql/history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/config"
export PSQLRC="${XDG_CONFIG_HOME}/psqlrc"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PYLINTHOME="${XDG_DATA_HOME}/pylint"
export PYTHONSTARTUP="/etc/pythonstart"
export REDISCLI_HISTFILE="${XDG_DATA_HOME}/redis/history"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export THEANORC="${XDG_CONFIG_HOME}/theano/.theanorc"
export THEANO_FLAGS="base_compiledir=${XDG_DATA_HOME}/theano"
export WINEPREFIX="${XDG_DATA_HOME}/wine/prefixes/default"

kubectl() {
    plugins="ctx deprecations doctor flame force-deploy images krew mtail ns outdated popeye"
    if echo "${plugins}" | grep -vw "${1:-DEFAULT}" >/dev/null; then
        command kubectl "$1" --cache-dir=${XDG_CACHE_HOME}/kube/http "${@:2}"
        return $?
    fi

    command kubectl "$@"
}

sqlite3() {
    rm -f ~/.sqlite_history && ln -s "${XDG_DATA_HOME}/sqlite/history" ~/.sqlite_history

    command sqlite3 -init "${XDG_CONFIG_HOME}/sqlite" "$@"
    (cd; rm .sqlite_history)
}

alias arc="arc --arcrc-file ${XDG_DATA_HOME}/arc/rc"
alias cpan="cpan -j ${XDG_CONFIG_HOME}/cpan/Config.pm"
# https://github.com/mbrt/gmailctl
alias gmailctl="gmailctl --config=${XDG_CONFIG_HOME}/gmailctl"
alias lmms="lmms --config=${XDG_CONFIG_HOME}/lmms/config"
alias wget="wget --hsts-file ${XDG_DATA_HOME}/wget/hsts"

export PATH="${KREW_ROOT}/bin:${PYENV_ROOT}/shims:${CARGO_HOME}/bin:${GOPATH}/bin:${PATH}"

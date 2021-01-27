if [[ "$OSTYPE" == "darwin"* ]]; then
    # convenience commands
    osx_clean() {
        sudo find "${1:-/}" -type f -name '*.DS_Store' -ls -delete
        sudo rm -rfv /Volumes/*/.Trashes
        sudo rm -rfv ~/.Trash
        sudo rm -rfv /private/var/log/asl/*.asl
    }
    # TODO: auto-fix the nosudo
    # echo 'kevin kjames-00564 = (root) NOPASSWD: /usr/bin/osascript' >> /etc/sudoers
    osx_volume() {
        if [ -z "${1}" ]; then
            # wtf
            printf "%.0f\n" $(( 7 * $(sudo osascript -e "output volume of (get Volume settings)") / 100. ))
        else
            osascript -e "set Volume ${1}"
        fi
    }

    # missing commands
    command -v md5sum > /dev/null || alias md5sum="md5"
    command -v sha1sum > /dev/null || alias sha1sum="shasum"

    # Fix compilations
    export ARCHFLAGS="-arch x86_64"

    # Because this will often work better than setting a real value
    export BROWSER="open"

    # Homebrew un-ratelimit
    export HOMEBREW_GITHUB_API_TOKEN="M4_HOMEBREW_GITHUB_API_TOKEN"

    # TODO: make user-installed deps the default on all systems
    # alternatively: figure out better setup for tasklib/neovim
    export PATH="${HOME}/Library/Python/3.7/bin:$PATH"

    # X11
    export DISPLAY=":0"
    export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"

    ulimit -n 2048
    ulimit -u 512
fi

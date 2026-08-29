# shellcheck shell=bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # convenience commands
    osx_mute() {
        osascript -e "set volume output muted true"
    }
    osx_unmute() {
        osascript -e "set volume output muted false"
    }
    osx_volume() {
        if [ -z "${1}" ]; then
            # wtf
            printf "%.0f\n" $(( 7 * $(sudo osascript -e "output volume of (get Volume settings)") / 100. ))
        else
            osascript -e "set Volume ${1}"
        fi
    }

    # missing commands
    command -v md5sum >/dev/null || alias md5sum="md5"
    command -v sha1sum >/dev/null || alias sha1sum="shasum"

    # alias coreutils when there are no BSD versions
    command -v gtimeout >/dev/null || alias timeout="gtimeout"

    # Fix compilations
    export ARCHFLAGS="-arch $(uname -m)"
    export RUSTFLAGS="-L/Library/Developer/CommandLineTools/SDKs/MacOSX$(sw_vers -productVersion).sdk/usr/lib"
    if [ "$(uname -m)" = "arm64" ]; then
        export DOCKER_DEFAULT_PLATFORM=linux/amd64
    fi

    # Because this will often work better than setting a real value
    export BROWSER="open"

    # X11
    export DISPLAY=":0"
    export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"

    # Some things (podman, at least) expect this to be user-owned
    export XDG_RUNTIME_DIR="/tmp/runtime"
    mkdir -p "${XDG_RUNTIME_DIR}"

    ulimit -n 2048
    ulimit -u 1024
fi

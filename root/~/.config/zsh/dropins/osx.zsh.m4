# shellcheck shell=bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # convenience commands
    osx_clean() {
        sudo find "${1:-/}" -type f -name '*.DS_Store' -ls -delete
        sudo rm -rfv /Volumes/*/.Trashes
        sudo rm -rfv ~/.Trash
        sudo rm -rfv /private/var/log/asl/*.asl
    }

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
    command -v md5sum > /dev/null || alias md5sum="md5"
    command -v sha1sum > /dev/null || alias sha1sum="shasum"

    # Fix compilations
    export ARCHFLAGS="-arch $(uname -m)"
    export RUSTFLAGS="-L/Library/Developer/CommandLineTools/SDKs/MacOSX$(sw_vers -productVersion).sdk/usr/lib"

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

# restart yabai / skhd services:
# yabai --start-service
# skhd --start-service

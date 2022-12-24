if [[ "$OSTYPE" == "darwin"* ]]; then
    # convenience commands
    osx_clean() {
        sudo find "${1:-/}" -type f -name '*.DS_Store' -ls -delete
        sudo rm -rfv /Volumes/*/.Trashes
        sudo rm -rfv ~/.Trash
        sudo rm -rfv /private/var/log/asl/*.asl
    }
    # TODO: auto-fix the nosudo
    # echo "$(whoami) $(hostname) = (root) NOPASSWD: /usr/bin/osascript" | sudo tee /etc/sudoers.d/osascript
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
    # TODO: m1 support
    export ARCHFLAGS="-arch x86_64"

    # Because this will often work better than setting a real value
    export BROWSER="open"

    # X11
    export DISPLAY=":0"
    export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"

    # Some things (podman, at least) expect this to be user-owned
    export XDG_RUNTIME_DIR="/tmp/runtime"
    mkdir -p "${XDG_RUNTIME_DIR}"

    ulimit -n 2048
    ulimit -u 512
fi

# TODO: grant sudoers permissions:
# echo "$(whoami) ALL=(ALL) NOPASSWD: $(which yabai)" | sudo tee /etc/sudoers.d/yabai
# echo "$(whoami) ALL=(ALL) NOPASSWD: $(which skhd)" | sudo tee /etc/sudoers.d/skhd

# restart yabai / skhd services:
# sudo launchctl bootout gui/$(id -u $(whoami)) /Library/LaunchAgents/org.macports.yabai.plist
# sudo launchctl bootstrap gui/$(id -u $(whoami)) /Library/LaunchAgents/org.macports.yabai.plist
# sudo launchctl bootout gui/$(id -u $(whoami)) /Library/LaunchAgents/org.macports.skhd.plist
# sudo launchctl bootstrap gui/$(id -u $(whoami)) /Library/LaunchAgents/org.macports.skhd.plist

if [[ "$OSTYPE" == "darwin"* ]]; then
    # convenience commands
    frameworkpython() {
        if [[ ! -z "${VIRTUAL_ENV}" ]]; then
            PYTHONHOME="${VIRTUAL_ENV}" /usr/local/bin/python "$@"
        else
            /usr/local/bin/python "$@"
        fi
    }

    osx_clean() {
        sudo find "${1:-/}" -type f -name '*.DS_Store' -ls -delete
        sudo rm -rfv /Volumes/*/.Trashes
        sudo rm -rfv ~/.Trash
        sudo rm -rfv /private/var/log/asl/*.asl
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

    # X11
    export DISPLAY=":0"
    export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"

    # reasonable defaults
    # key repeat > key hold
    defaults write -g ApplePressAndHoldEnabled -bool false
    defaults write NSGlobalDomain KeyRepeat -int 0
    # use list view in finder
    defaults write com.apple.Finder FXPreferredViewStyle Nlsv
    # do not create .DS_Store files on network drives
    defaults write com.apple.desktopservices DSDontWriteNetworkStores true
    # show ~/Library
    chflags nohidden ~/Library
    # show removables on desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    ulimit -n 2048
    ulimit -u 512
fi

# shellcheck shell=bash
if [[ "$OSTYPE" == "linux"* ]]; then
    alias open="xdg-open"

    if [[ -f /proc/version ]]; then
        if grep -q Microsoft /proc/version; then
            # TODO: update to WSL >= v17738
            unsetopt BG_NICE
        fi
    fi
fi

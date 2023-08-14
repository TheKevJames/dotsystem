# shellcheck shell=bash
export XDG_BIN_HOME=~/.local/bin
export XDG_CACHE_HOME=~/.cache
export XDG_CONFIG_HOME=~/.config
export XDG_DATA_HOME=~/.local/share
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
export XDG_SRC_HOME=~/.local/src
export XDG_STATE_HOME=~/.local/state

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

CC=$(command -v clang || echo /usr/bin/clang)
CXX=$(command -v clang++ || echo /usr/bin/clang++)
export CC
export CXX

EDITOR=$(command -v nvim || echo /opt/local/bin/nvim)
export EDITOR
export TERM=xterm-256color

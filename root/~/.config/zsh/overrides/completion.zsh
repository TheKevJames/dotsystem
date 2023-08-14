# shellcheck shell=bash
export CASE_SENSITIVE=false
export COMPLETION_WAITING_DOTS=true
export HYPHEN_INSENSITIVE=true
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-~/cache}/zsh"

# do not autocomplete from /etc/hosts
zstyle ':completion:*' hosts off

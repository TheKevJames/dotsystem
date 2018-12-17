export XDG_BIN_HOME=~/.local/bin
export XDG_CACHE_HOME=~/.cache
export XDG_CONFIG_HOME=~/.config
export XDG_DATA_HOME=~/.local/share

export ZDOTDIR=${XDG_CONFIG_HOME}/zsh

export CC=$(command -v clang || echo /usr/bin/clang)
export CXX=$(command -v clang++ || echo /usr/bin/clang++)

export EDITOR=$(command -v nvim || echo /usr/local/bin/nvim)
export TERM=xterm-256color

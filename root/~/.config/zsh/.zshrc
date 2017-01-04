export ZSH="${XDG_CONFIG_HOME}/oh-my-zsh"

ZSH_THEME="jreese"

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"

DISABLE_AUTO_UPDATE="false"
export UPDATE_ZSH_DAYS=6

DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

DISABLE_UNTRACKED_FILES_DIRTY="false"

HISTFILE="${XDG_DATA_HOME}/zsh/history"
HIST_STAMPS="yyyy-mm-dd"

ZSH_CUSTOM="${XDG_CONFIG_HOME}/oh-my-zsh-custom"
plugins=(git vi-mode)


source $ZSH/oh-my-zsh.sh

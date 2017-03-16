export ZSH="${XDG_CONFIG_HOME}/oh-my-zsh"

ZSH_THEME="kevin"

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"

DISABLE_AUTO_UPDATE="false"
export UPDATE_ZSH_DAYS=6

DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"

ENABLE_CORRECTION="false"

COMPLETION_WAITING_DOTS="true"

DISABLE_UNTRACKED_FILES_DIRTY="false"

HISTFILE="${XDG_DATA_HOME}/zsh/history"
HIST_STAMPS="yyyy-mm-dd"

ZSH_CUSTOM="${XDG_CONFIG_HOME}/oh-my-zsh-custom"
plugins=(cargo docker docker-compose extract git-prompt shrink-path)

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

source $ZSH/oh-my-zsh.sh

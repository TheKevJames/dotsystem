source "${XDG_DATA_HOME}/nvim/plugged/fzf/shell/completion.zsh" 2> /dev/null
source "${XDG_DATA_HOME}/nvim/plugged/fzf/shell/key-bindings.zsh"

export FZF_DEFAULT_COMMAND='fd -u --type f'
export FZF_DEFAULT_OPTS='--height 40% --border'
export PATH="${XDG_DATA_HOME}/nvim/plugged/fzf/bin:${PATH}"

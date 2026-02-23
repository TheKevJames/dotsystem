# shellcheck shell=bash
# https://github.com/sharkdp/bat
alias less='bat'
PAGER="$(type -p less | awk '{print $NF}')"  # ie. PAGER=/path/to/less
export PAGER
export LESS='-R'

# https://eza.rocks/
alias l='eza -la --group-directories-first'
alias la='eza -la --group-directories-first'
alias ll='eza -l --group-directories-first'
alias ls='eza --group-directories-first'
alias lsa='eza -la --group-directories-first'
export TIME_STYLE=long-iso

# http://denilson.sa.nom.br/prettyping/
alias ping='prettyping'

# https://github.com/aristocratos/btop
alias top='btop'

# https://github.com/neovim/neovim
alias vim='nvim'
export MANPAGER='nvim +Man!'

# https://github.com/sharkdp/hexyl
alias xxd='hexyl'

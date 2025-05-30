# shellcheck shell=bash
# https://github.com/sharkdp/bat
# alias cat='bat'
alias less='bat'
PAGER="$(type -p less | awk '{print $NF}')"  # ie. PAGER=/path/to/less
export PAGER
export MANPAGER="sh -c 'col -b | bat -l man -p'"
export LESS='-R'

# https://eza.rocks/
alias l='eza -la'
alias la='eza -la'
alias ll='eza -l'
alias ls='eza'
alias lsa='eza -la'
export TIME_STYLE=long-iso

# http://denilson.sa.nom.br/prettyping/
alias ping='prettyping'

# https://github.com/aristocratos/btop
alias top='btop'

# https://github.com/neovim/neovim
alias vim='nvim'

# https://github.com/sharkdp/hexyl
alias xxd='hexyl'

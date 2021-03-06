# https://github.com/sharkdp/bat
# alias cat='bat'
alias less='bat'
export PAGER="$(type -p less | awk '{print $NF}')"  # ie. PAGER=/path/to/less
export MANPAGER="sh -c 'col -b | bat -l man -p'"
export LESS='-R'

# https://the.exa.website/
alias l='exa -la'
alias la='exa -la'
alias ll='exa -l'
alias ls='exa'
alias lsa='exa -la'

# http://denilson.sa.nom.br/prettyping/
alias ping='prettyping'

# https://hisham.hm/htop/
alias top='htop'

# https://github.com/neovim/neovim
alias vim='nvim'

# https://github.com/sharkdp/hexyl
alias xxd='hexyl'

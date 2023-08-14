# shellcheck shell=bash
# Yoinked starting point from:
# https://github.com/robbyrussell/oh-my-zsh/blob/52fdae4b3d17f7ab602124ec8792865b5fc03236/lib/key-bindings.zsh

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init() {
        echoti smkx
    }
    function zle-line-finish() {
        echoti rmkx
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# Use emacs key bindings
bindkey -e

# [Esc-w] - Kill from the cursor to the mark
bindkey '\ew' kill-region

# [Ctrl-r] - search backward incrementally for a specified string. Augmented with fzf.
fzf-history-widget-accept() {
    fzf-history-widget
    zle accept-line
}
zle     -N   fzf-history-widget-accept
bindkey '^r' fzf-history-widget-accept
# bindkey '^r' history-incremental-search-backward

# [Ctrl-t] - search backward from current partial command
bindkey '^t' history-beginning-search-backward
# [Ctrl-y] - noop (defaults to "yank" operation)
bindkey -s '^y' ''

# start typing + [Up-Arrow] - fuzzy find history forward
# shellcheck disable=SC2154
if [[ "${terminfo[kcuu1]}" != "" ]]; then
    autoload -U up-line-or-beginning-search
    zle -N up-line-or-beginning-search
    bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${terminfo[kcud1]}" != "" ]]; then
    autoload -U down-line-or-beginning-search
    zle -N down-line-or-beginning-search
    bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Space] - do history expansion
bindkey ' ' magic-space

# [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey '^[[1;5D' backward-word

# [Shift-Tab] - move through the completion menu backwards
if [[ "${terminfo[kcbt]}" != "" ]]; then
    bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Backspace] - delete backward
bindkey '^?' backward-delete-char
# [Delete] - delete forward
if [[ "${terminfo[kdch1]}" != "" ]]; then
    bindkey "${terminfo[kdch1]}" delete-char
else
    bindkey "^[[3~" delete-char
    bindkey "^[3;5~" delete-char
    bindkey "\e[3~" delete-char
fi

# file rename magick
bindkey "^[m" copy-prev-shell-word

# fix bracketed pasting
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# never `cd` when command_not_found is a directory
unsetopt auto_cd

# implicit `cat` and `tee` when redirecting
setopt multios

# Yoinked from https://github.com/statico/dotfiles/blob/0053e9d1c2bd6564075ea9bf02ffa3de5cc86e3a/.zshrc#L512-L522
# Disables the behaviours where the <space> is removed after typing eg. "filepref<tab>|", etc.
self-insert-redir() {
    integer l=$#LBUFFER
    zle self-insert
    # shellcheck disable=SC2004,SC2154
    (( $l >= $#LBUFFER )) && LBUFFER[-1]=" ${LBUFFER[-1]}"
}
zle -N self-insert-redir
for op in \| \< \> \& ; do
    bindkey "$op" self-insert-redir
done

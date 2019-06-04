# allow comments in commands
setopt interactivecomments

# enable prompt expansion
setopt prompt_subst

# use fish-style paths, see ../plugins/shrink-path.plugin.zsh
zstyle :prompt:shrink_path fish no

# TODO: could add "@${LINENO}"
local return_code="%(?..%{$fg[red]%} %?%{$reset_color%})"

# user@domain:
#     if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
#     %{$fg[$NCOLOR]%}%n%{$fg[green]%}@%m%{$reset_color%}
PROMPT='$(shrink_path -l -t)${return_code} %{$fg[red]%}%(!.#.»)%{$reset_color%} '

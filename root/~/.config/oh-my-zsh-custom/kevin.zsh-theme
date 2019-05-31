# Based on "jreese"

zstyle :prompt:shrink_path fish no

if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
# TODO: could add "@${LINENO}"
local return_code="%(?..%{$fg[red]%} %?%{$reset_color%})"

# user@domain: %{$fg[$NCOLOR]%}%n%{$fg[green]%}@%m%{$reset_color%}
PROMPT='$(shrink_path -l -t)${return_code} %{$fg[red]%}%(!.#.»)%{$reset_color%} '

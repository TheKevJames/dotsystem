# zmodload zsh/zprof

export PATH="${HOME}/.local/bin:/opt/local/sbin:/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# TODO: is this OSX-only or on all my systems?
if [[ -z "$LC_CTYPE" && -z "$LC_ALL" ]]; then
    export LC_CTYPE=${LANG%%:*}
fi

for config_file (~/.config/zsh/plugins/*.zsh); do
    source $config_file
done

for config_file (~/.config/zsh/dropins/*.zsh); do
    source $config_file
done

# TODO: load `~/secrets` (see `~/.config/zsh/dropins/*-*.zsh`)

unset config_file

# https://gist.github.com/ctechols/ca1035271ad134841284
_zpcompinit_custom() {
  setopt extendedglob local_options
  autoload -Uz compinit
  local zcd="${ZDOTDIR:-$HOME}/.zcompdump-${ZSH_VERSION}"
  local zcdc="$zcd.zwc"
  # Compile the completion dump to increase startup speed, if dump is newer or doesn't exist,
  # in the background as this is doesn't affect the current session
  if [[ -f "$zcd"(#qN.m+1) ]]; then
        compinit -i -d "$zcd"
        { rm -f "$zcdc" && zcompile "$zcd" } &!
  else
        compinit -C -d "$zcd"
        { [[ ! -f "$zcdc" || "$zcd" -nt "$zcdc" ]] && rm -f "$zcdc" && zcompile "$zcd" } &!
  fi
}
_zpcompinit_custom

# zprof

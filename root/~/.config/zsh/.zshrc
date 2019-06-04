# zmodload zsh/zprof
ZSH_COMPDUMP="~/.config/zsh/.zcompdump-${ZSH_VERSION}"
autoload -U compaudit compinit
compinit -i -C -d "${ZSH_COMPDUMP}"

export PATH="${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

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
# zprof

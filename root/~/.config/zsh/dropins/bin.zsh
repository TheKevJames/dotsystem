alias tmpenv="source ${XDG_DATA_HOME}/dotsystem/tmpenv.sh"

# Sync cwd across shells, stolen from:
# https://github.com/statico/dotfiles/blob/31899c42000219a8b4dbd2b4857af5cb98b38358/.zshrc#L378-L386
tmpdir="${TMPDIR:-/tmp}"
pin() {
  rm -f "${tmpdir}/pindir"
  (umask 0177; echo $PWD >"${tmpdir}/pindir")
}
pout() {
  cd $(cat "${tmpdir}/pindir")
}

# fzf a file and open it.
# * CTRL-O to open with `open` command,
# * CTRL-E or Enter key to open with the $EDITOR
# https://github.com/junegunn/fzf/wiki/Examples#opening-files
fzfopen() {
  IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

autoload -U colors && colors

# TODO: how best to handle PATH config order? Currently, dropin load order is
# undefined (alphabetical?), an color.sh < xdg.sh, so vivid isn't yet on the
# path.
VIVID_DIR="${XDG_DATA_HOME}/cargo/bin"
export LS_COLORS=$("${VIVID_DIR}/vivid" generate gruvbox-dark)

# TODO: colorize based on hostname
# TODO: support for eg. `gcloud compute ssh ...`
# TODO: alias as ssh
# TODO: change LS_COLORS instead of terminal stuff, so it's cross-emulator compatible
function colorssh() {
  sd '^colors: \*\w+$' 'colors: *red' ~/.config/alacritty/alacritty.yml
  trap "sd '^colors: \*\w+$' 'colors: *default' ~/.config/alacritty/alacritty.yml" EXIT

  ssh $*
}

autoload -U colors && colors

# TODO: colorize based on hostname
# TODO: support for eg. `gcloud compute ssh ...`
# TODO: alias as ssh
# TODO: change LS_COLORS instead of terminal stuff, so it's cross-emulator compatible
function colorssh() {
  sd '^colors: \*\w+$' 'colors: *red' ~/.config/alacritty/alacritty.yml
  trap "sd '^colors: \*\w+$' 'colors: *default' ~/.config/alacritty/alacritty.yml" EXIT

  ssh $*
}

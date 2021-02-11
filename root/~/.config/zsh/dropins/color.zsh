autoload -U colors && colors

# TODO: colorize based on hostname
# TODO: support for eg. `gcloud compute ssh ...`
# TODO: alias as ssh
function colorssh() {
  sd '^colors: \*\w+$' 'colors: *red' ~/.config/alacritty/alacritty.yml
  trap "sd '^colors: \*\w+$' 'colors: *default' ~/.config/alacritty/alacritty.yml" EXIT

  ssh $*
}

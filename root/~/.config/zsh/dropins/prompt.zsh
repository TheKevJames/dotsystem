# TODO: can we do this by updating the `fg`/`bg` dicts instead?
# TODO: this should really lives in `colorz.zsh`...
local gruvbox_bg=$'\e[38;2;40;40;40m'
local gruvbox_fg=$'\e[38;2;235;219;178m'

local gruvbox_black=$'\e[38;2;40;40;40m'
local gruvbox_red=$'\e[38;2;204;36;29m'
local gruvbox_green=$'\e[38;2;152;151;26m'
local gruvbox_yellow=$'\e[38;2;215;153;33m'
local gruvbox_blue=$'\e[38;2;69;133;136m'
local gruvbox_magenta=$'\e[38;2;177;98;134m'
local gruvbox_cyan=$'\e[38;2;104;157;106m'
local gruvbox_white=$'\e[38;2;168;153;132m'

local gruvbox_black_bright=$'\e[38;2;146;131;116m'
local gruvbox_red_bright=$'\e[38;2;251;73;52m'
local gruvbox_green_bright=$'\e[38;2;184;187;38m'
local gruvbox_yellow_bright=$'\e[38;2;250;189;47m'
local gruvbox_blue_bright=$'\e[38;2;131;165;152m'
local gruvbox_magenta_bright=$'\e[38;2;211;134;155m'
local gruvbox_cyan_bright=$'\e[38;2;142;192;124m'
local gruvbox_white_bright=$'\e[38;2;235;219;178m'

setopt interactivecomments  # allow comments in commands
setopt prompt_subst         # enable prompt expansion

# use fish-style paths, see ../plugins/shrink-path.plugin.zsh
zstyle :prompt:shrink_path fish no

local return_color="%(?.%{$gruvbox_green%}.%{$gruvbox_red%})"
# TODO: why is my foreground color not consistent?
# PROMPT=$'%{$gruvbox_fg%}$(shrink_path -l -t)${return_code} %{$gruvbox_green%}%(!.#.»)%{$reset_color%} '
PROMPT=$'%{$reset_color%}$(shrink_path -l -t) ${return_color}%(!.#.»)%{$reset_color%} '

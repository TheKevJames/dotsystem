# shellcheck shell=bash
# convert from 256bit to 8bit color
declare -A GIT_PROMPT_SYMBOLS
# shellcheck disable=SC2034,SC2190
GIT_PROMPT_SYMBOLS=(
    "prefix" "%F{7}[%f"
    "branch" "%F{2}"
    "behind" "%F{1}%{←%G%}"
    "ahead" "%F{1}%{→%G%}"
    "separator" "%F{7}|%f"
    "staged" "%F{6}%{♦%G%}"
    "changed" "%F{3}%{◊%G%}"
    "conflicts" "%F{1}%{≠%G%}"
    "untracked" "%F{5}%{…%G%}"
    "clean" "%F{2}%B%{✓%G%}%b"
    "suffix" "%F{7}]%f"
)

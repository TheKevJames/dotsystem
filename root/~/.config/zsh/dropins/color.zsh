# shellcheck shell=bash
autoload -U colors && colors

source "$(dirname "$(realpath "$0")")/xdg.zsh"
LS_COLORS=$(vivid generate gruvbox-dark)
export LS_COLORS

declare -A HOSTNAME_COLORS=(
    ["applebox"]=red
    ["bmaxbox"]=red
    ["pi-0"]=red
    ["pi-1"]=red
)

function update_tmux_ssh {
    HOSTNAME="${1:-}"
    tmux set-option -p @custom_pane_color "${HOSTNAME_COLORS[$HOSTNAME]:-terminal}"
    [[ -n "${HOSTNAME}" ]] && HOSTNAME="${HOSTNAME} "
    tmux set-option -p @custom_pane_title "${HOSTNAME}"
}

function update_tmux_gcp {
    GCP=$(cat ~/.config/gcloud/active_config 2>/dev/null || echo "N/A")
    tmux set-option -g @custom_window_gcp_title "${GCP}"
    if grep -E 'echelon|production' <(echo "${GCP}") >/dev/null; then
        tmux set-option -g @custom_window_gcp_color 'red'
    else
        tmux set-option -g @custom_window_gcp_color 'green'
    fi
}

function gcloud {
    if [[ "$*" == *" ssh "* ]]; then
        update_tmux_ssh "${@:$#}"
        command gcloud "$@"
        update_tmux_ssh ""
    else
        command gcloud "$@"
    fi
    update_tmux_gcp
}

function ssh {
    if [[ $(ps -p "$(ps -p$$ -oppid=)" -ocomm=) =~ "tmux" ]]; then
        update_tmux_ssh "${*:$#}"
        command ssh "$@"
        update_tmux_ssh
    else
        command ssh "$@"
    fi
}

# TODO: run these once on tmux startup rather than on every new shell/pane.
# They already re-run when a gcloud command might change them, so
# invoking them for each new pane is superfluous.
update_tmux_gcp

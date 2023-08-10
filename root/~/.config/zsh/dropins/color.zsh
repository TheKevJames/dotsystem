autoload -U colors && colors

# TODO: how best to handle PATH config order? Currently, dropin load order is
# undefined (alphabetical?), an color.sh < xdg.sh, so vivid isn't yet on the
# path.
VIVID_DIR="${XDG_DATA_HOME}/cargo/bin"
export LS_COLORS=$("${VIVID_DIR}/vivid" generate gruvbox-dark)

declare -A HOSTNAME_COLORS=(
    ["applebox"]=green
    ["pi-0"]=green
    ["pi-1"]=green
)

function update_tmux_ssh() {
    HOSTNAME="${1:-}"
    tmux set-option -p @custom_pane_title "${HOSTNAME}"
    tmux set-option -p @custom_pane_color "${HOSTNAME_COLORS[$HOSTNAME]:-terminal}"
}

function update_tmux_gcp() {
    GCP=$(cat ~/.config/gcloud/active_config)
    tmux set-option -g @custom_window_gcp_title "${GCP}"
    if grep -E 'echelon|production' <(echo "${GCP}") >/dev/null; then
        tmux set-option -g @custom_window_gcp_color 'red'
    else
        tmux set-option -g @custom_window_gcp_color 'green'
    fi
}

function update_tmux_k8s() {
    K8S=$(awk '/current-context:/ {print $2}' ~/.config/kube)
    tmux set-option -g @custom_window_k8s_title "${K8S}"
    if grep -E 'echelon|production' <(echo "${K8S}") >/dev/null; then
        tmux set-option -g @custom_window_k8s_color 'red'
    else
        tmux set-option -g @custom_window_k8s_color 'green'
    fi
}

function gcloud() {
    if [[ "$@" =~ " ssh " ]]; then
        echo update_tmux_ssh "${@:$#}"
        echo running gcloud "$@"
        echo update_tmux_ssh ""
    else
        echo gcloud "$@"
    fi
    update_tmux_gcp
}

function kubectl() {
    command kubectl "$@"
    update_tmux_k8s
}

function ssh() {
    if [[ $(ps -p $(ps -p$$ -oppid=) -ocomm=) =~ "tmux" ]]; then
        update_tmux_ssh "${@:$#} "
        command ssh "$@"
        update_tmux_ssh
    else
        command ssh "$@"
    fi
}

# TODO: on tmux startup only
update_tmux_gcp
update_tmux_k8s

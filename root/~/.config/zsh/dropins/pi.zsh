# shellcheck shell=bash
export PI_CODING_AGENT_DIR="${HOME}/src/personal/bakery/interactive"
export PI_CODING_AGENT_STATE_DIR="${XDG_STATE_HOME}/pi"
export PI_CODING_AGENT_SESSION_DIR="${XDG_STATE_HOME}/pi/sessions"

dialpad-pi() {
    PI_CODING_AGENT_DIR="${HOME}/src/dialpad/pi-profile/agent" \
    PI_CODING_AGENT_STATE_DIR="${HOME}/src/dialpad/pi-profile/state" \
    PI_CODING_AGENT_SESSION_DIR="${HOME}/src/dialpad/pi-profile/state/sessions" \
        pi "$@"
}

source "${XDG_SRC_HOME}/google-cloud-sdk/completion.zsh.inc"

export PATH="${XDG_SRC_HOME}/google-cloud-sdk/bin:${PATH}"

# otherwise it prioritizes py2 over py3
export CLOUDSDK_PYTHON=python3

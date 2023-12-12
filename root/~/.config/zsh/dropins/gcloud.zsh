# shellcheck shell=bash
export PATH="${XDG_SRC_HOME}/google-cloud-sdk/bin:${PATH}"

CLOUDSDK_PYTHON=$(which python3.11)
export CLOUDSDK_PYTHON

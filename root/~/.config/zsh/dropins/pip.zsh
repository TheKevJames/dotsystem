# shellcheck shell=bash
export PIP_KEYRING_PROVIDER=subprocess

export VOICEAI_PYPI="https://oauth2accesstoken@us-python.pkg.dev/voiceai-infra/voiceai-pypi/simple/"
pip-private()  { PIP_EXTRA_INDEX_URL="$VOICEAI_PYPI" command pip "$@"; }
pipx-private() { PIP_EXTRA_INDEX_URL="$VOICEAI_PYPI" command pipx "$@"; }
uv-private() { PIP_EXTRA_INDEX_URL="$VOICEAI_PYPI" command uv "$@"; }

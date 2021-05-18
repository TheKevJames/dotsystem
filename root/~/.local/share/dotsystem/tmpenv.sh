DIR=$(mktemp -d -t $(basename "${0}"))
python3 -m venv "${DIR}"
source "${DIR}/bin/activate"

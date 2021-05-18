if [[ "$(basename -- "$0")" == "tmpenv.sh" ]]; then
    echo "tmpenv.sh must be sourced; run 'tmpenv' directly" >&2
    exit 1
fi

DIR=$(mktemp -d -t $(basename "${0}"))
python3 -m venv "${DIR}"
source "${DIR}/bin/activate"

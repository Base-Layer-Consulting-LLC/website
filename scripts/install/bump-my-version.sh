#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "${THIS_DIR}/_common.sh"

if has_cmd bump-my-version; then
  echo "bump-my-version already installed"
  exit 0
fi

py=""
if py="$(python_bin 2>/dev/null)"; then
  :
else
  install_cmd python3 || install_cmd python
  py="$(python_bin)"
fi

"$py" -m pip install --user --upgrade pip
"$py" -m pip install --user bump-my-version

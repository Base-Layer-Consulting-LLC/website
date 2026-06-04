#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "${THIS_DIR}/_common.sh"

if has_cmd curl; then
  echo "curl already installed"
  exit 0
fi

install_cmd curl

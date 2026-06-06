#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT=$(realpath -m "${THIS_DIR}/../..")

cd "${REPO_ROOT}"

BASE_BRANCH="${1:-main}"

if git diff --name-only "origin/${BASE_BRANCH}...HEAD" |
  grep -qE '^\.containers/ci/'; then
  echo "changed=true"
else
  echo "changed=false"
fi

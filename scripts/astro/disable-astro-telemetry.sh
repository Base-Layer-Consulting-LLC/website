#!/usr/bin/env bash

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT=$(realpath -m "${THIS_DIR}/../..")
SITE_DIR="${REPO_ROOT}/site"

CWD=$(pwd)

function cleanup() {
  cd "${CWD}" || true
}
trap cleanup EXIT

if ! command -v npm >&/dev/null; then
  echo "[ERROR] np is not installed" >&2
  echo "Try running this manually: astro telemetry disable" >&2
  exit 1
fi

cd "${SITE_DIR}" || true

echo "Disabling Astro telemetry"

npm run astro telemetry disable

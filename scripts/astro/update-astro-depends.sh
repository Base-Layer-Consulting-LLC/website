#!/usr/bin/bash

if ! command -v npx >&/dev/null; then
  echo "[ERROR] npx is not installed"
  exit 1
fi

THIS_DIR="$(dirname "${0}")"
ROOT_DIR=$(realpath -m "${THIS_DIR}/../..")
ASTRO_ROOT="${ROOT_DIR}/site"

CWD=$(pwd)

function cleanup() {
  cd "${CWD}" || true
}
trap cleanup EXIT

echo ""
echo "Updating Astro & integrations"

cd "${ASTRO_ROOT}" || exit

if ! npx @astrojs/upgrade 2>&1; then
  echo "[ERROR] Failed running Astro upgrade"
  exit 1
fi

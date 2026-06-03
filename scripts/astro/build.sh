#!/usr/bin/env bash

THIS_DIR="$(dirname "${0}")"
REPO_ROOT=$(realpath -m "${THIS_DIR}/../..")
ASTRO_ROOT="${REPO_ROOT}/site"
CWD="$(pwd)"

function cleanup() {
  cd "${CWD}" || true
}
trap cleanup EXIT

echo ""
echo "Building Astro site"
echo ""

cd "$ASTRO_ROOT" || exit

if ! npm run build 2>&1; then
  echo "[ERROR] Failed building Astro site" >&2
  exit 1
fi

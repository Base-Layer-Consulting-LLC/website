#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(realpath -m "${THIS_DIR}/../..")"
ASTRO_ROOT="${REPO_ROOT}/site"
CWD="$(pwd)"

function cleanup() {
  cd "${CWD}" || true
}
trap cleanup EXIT

echo ""
echo "Building Astro site"
echo ""

cd "$ASTRO_ROOT" || exit 1

if ! ASTRO_TELEMETRY_DISABLED=1 npm run build 2>&1; then
  echo "[ERROR] Failed building Astro site" >&2
  exit 1
fi

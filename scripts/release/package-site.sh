#!/usr/bin/env bash
set -euo pipefail

#######################################################################
# Copy VERSION file into site/ directory, then create .tar.gz archive #
#######################################################################

DRY_RUN=false

function usage() {
  echo "Usage: $0 [--dry-run]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "[ERROR] Unknown arg: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(realpath -m "${THIS_DIR}/../..")"

VERSION="$(<"${REPO_ROOT}/VERSION")"
BUILD_DIR="${REPO_ROOT}/site/dist"
ARCHIVE_NAME="site-v${VERSION}.tar.gz"
TMP_BUILD_DIR="${REPO_ROOT}/.release-site"

rm -rf "$TMP_BUILD_DIR"
cp -R "$BUILD_DIR" "$TMP_BUILD_DIR"
cp "${REPO_ROOT}/VERSION" "${TMP_BUILD_DIR}/VERSION"

tar -C "$TMP_BUILD_DIR" -czf "${REPO_ROOT}/${ARCHIVE_NAME}" .
rm -rf "$TMP_BUILD_DIR"

echo "${ARCHIVE_NAME}"

if $DRY_RUN; then
  echo "Dry run: archive created locally only"
fi

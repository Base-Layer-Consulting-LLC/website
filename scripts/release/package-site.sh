#!/usr/bin/env bash
set -euo pipefail

#######################################################################
# Copy VERSION file into site/dist, then create .tar.gz archive        #
#######################################################################

DRY_RUN=false
VERSION=""

function usage() {
  echo "Usage: $0 [--dry-run] [--version <version>]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --version)
    VERSION="${2:-}"
    shift 2
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

if [[ -z "$VERSION" ]]; then
  VERSION="$(<"${REPO_ROOT}/VERSION")"
fi

BUILD_DIR="${REPO_ROOT}/site/dist"
ARCHIVE_NAME="site-v${VERSION}.tar.gz"
TMP_BUILD_DIR="${REPO_ROOT}/.release-site"

if $DRY_RUN; then
  echo "Dry run: would create ${ARCHIVE_NAME}"
  exit 0
fi

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "[ERROR] Build directory not found: $BUILD_DIR" >&2
  exit 1
fi

rm -rf "$TMP_BUILD_DIR"
mkdir -p "$TMP_BUILD_DIR"
cp -R "$BUILD_DIR"/. "$TMP_BUILD_DIR"/
cp "${REPO_ROOT}/VERSION" "${TMP_BUILD_DIR}/VERSION"

tar -C "$TMP_BUILD_DIR" -czf "${REPO_ROOT}/${ARCHIVE_NAME}" .
rm -rf "$TMP_BUILD_DIR"

echo "${ARCHIVE_NAME}"

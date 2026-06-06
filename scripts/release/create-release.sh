#!/usr/bin/env bash
set -euo pipefail

##########################################################
# Create a tagged release of the site archive on Github. #
##########################################################

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
ROOT_DIR="$(realpath -m "${THIS_DIR}/../..")"

if [[ -z "$VERSION" ]]; then
  VERSION="$(<"${ROOT_DIR}/VERSION")"
fi

ARCHIVE_NAME="site-v${VERSION}.tar.gz"
TAG_NAME="v${VERSION}"
RELEASE_NAME="site-v${VERSION}"

if $DRY_RUN; then
  echo "Would create release: ${RELEASE_NAME}"
  echo "Would use tag: ${TAG_NAME}"
  echo "Would upload asset: ${ARCHIVE_NAME}"
  exit 0
fi

gh release create "$TAG_NAME" "${ROOT_DIR}/${ARCHIVE_NAME}" \
  --title "$RELEASE_NAME" \
  --notes "Release ${RELEASE_NAME}"

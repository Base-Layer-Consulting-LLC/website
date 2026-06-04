#!/usr/bin/env bash
set -euo pipefail

##########################################################
# Create a tagged release of the site archive on Github. #
##########################################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(realpath -m "${THIS_DIR}/../..")"
VERSION="$(<"${ROOT_DIR}/VERSION")"
ARCHIVE_NAME="site-v${VERSION}.tar.gz"
TAG_NAME="v${VERSION}"
RELEASE_NAME="site-v${VERSION}"

gh release create "$TAG_NAME" "${ROOT_DIR}/${ARCHIVE_NAME}" \
  --title "$RELEASE_NAME" \
  --notes "Release ${RELEASE_NAME}"

#!/usr/bin/env bash
set -euo pipefail

#######################################################################
# Copy VERSION file into site/ directory, then create .tar.gz archive #
#######################################################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(realpath -m "${THIS_DIR}/../..")"

VERSION="$(<"${ROOT_DIR}/VERSION")"
SITE_DIR="${ROOT_DIR}/site"
TMP_SITE_DIR="${ROOT_DIR}/.release-site"
ARCHIVE_NAME="site-v${VERSION}.tar.gz"

rm -rf "$TMP_SITE_DIR"
cp -R "$SITE_DIR" "$TMP_SITE_DIR"
cp "${ROOT_DIR}/VERSION" "${TMP_SITE_DIR}/VERSION"

tar -C "$TMP_SITE_DIR" -czf "${ROOT_DIR}/${ARCHIVE_NAME}" .
rm -rf "$TMP_SITE_DIR"

echo "${ARCHIVE_NAME}"

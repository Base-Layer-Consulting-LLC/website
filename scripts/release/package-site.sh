#!/usr/bin/env bash
set -euo pipefail

#######################################################################
# Copy VERSION file into site/ directory, then create .tar.gz archive #
#######################################################################

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

#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Ensures the current version in the VERSION file has a tag & Github release. #
###############################################################################

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

VERSION="${INPUT_VERSION:-}"

if [[ -z "$VERSION" ]]; then
  VERSION="$(<VERSION)"
fi

DRY_RUN="${INPUT_DRY_RUN:-false}"
TAG_NAME="v${VERSION}"
RELEASE_NAME="site-v${VERSION}"
ARCHIVE_NAME="site-v${VERSION}.tar.gz"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Would repair missing release for ${TAG_NAME}"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "version=$VERSION" >>"$GITHUB_OUTPUT"
  else
    echo "version=$VERSION"
  fi
  exit 0
fi

if gh release view "$TAG_NAME" >/dev/null 2>&1; then
  echo "Release already exists for ${TAG_NAME}"
else
  if [[ ! -f "${ROOT_DIR}/${ARCHIVE_NAME}" ]]; then
    echo "[ERROR] Missing asset: ${ARCHIVE_NAME}" >&2
    exit 1
  fi

  gh release create "$TAG_NAME" "${ROOT_DIR}/${ARCHIVE_NAME}" \
    --title "$RELEASE_NAME" \
    --notes "Release ${RELEASE_NAME}"

  echo "Created release ${TAG_NAME}"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "version=$VERSION" >>"$GITHUB_OUTPUT"
else
  echo "version=$VERSION"
fi

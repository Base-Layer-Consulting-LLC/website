#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Ensures the current version in the VERSION file has a tag & Github release. #
###############################################################################

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

VERSION="${INPUT_VERSION:-}"
DRY_RUN="${INPUT_DRY_RUN:-false}"

if [[ -z "$VERSION" ]]; then
  VERSION="$(<VERSION)"
fi

TAG_NAME="v${VERSION}"
ASSET_NAME="site-v${VERSION}.tar.gz"

function emit_version() {
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    echo "version=$VERSION" >>"$GITHUB_OUTPUT"
  else
    echo "version=$VERSION"
  fi
}

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Would repair release for ${TAG_NAME}"
  emit_version
  exit 0
fi

if [[ ! -f "$ASSET_NAME" ]]; then
  npm ci --prefix site
  (cd site && npm run build)
  ./scripts/release/package-site.sh --version "$VERSION"
fi

if gh release view "$TAG_NAME" >/dev/null 2>&1; then
  gh release upload "$TAG_NAME" "$ASSET_NAME" --clobber
else
  gh release create "$TAG_NAME" "$ASSET_NAME" \
    --title "site-v${VERSION}" \
    --notes "Release site-v${VERSION}"
fi

emit_version

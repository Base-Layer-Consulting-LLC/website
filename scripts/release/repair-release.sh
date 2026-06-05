#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Ensures the current version in the VERSION file has a tag & Github release. #
###############################################################################

DRY_RUN="${INPUT_DRY_RUN:-false}"
VERSION="${INPUT_VERSION:-}"
COMMIT_SHA=""

function usage() {
  cat <<EOF
Usage:
  $0 [--dry-run] [--version <version>] [--commit <sha>]
EOF
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
  --commit)
    COMMIT_SHA="${2:-}"
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

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if [[ -n "$COMMIT_SHA" ]]; then
  echo "Checking out commit: $COMMIT_SHA"
  git checkout --detach "$COMMIT_SHA"
fi

if [[ -z "$VERSION" ]]; then
  VERSION="$(<VERSION)"
fi

TAG_NAME="v${VERSION}"
RELEASE_NAME="site-${TAG_NAME}"
ARCHIVE_NAME="site-${TAG_NAME}.tar.gz"

tag_exists=false
if git rev-parse -q --verify "refs/tags/${TAG_NAME}" >/dev/null; then
  tag_exists=true
fi

release_exists=false
if gh release view "$TAG_NAME" >/dev/null 2>&1; then
  release_exists=true
fi

echo "Version: ${VERSION}"
echo "Tag: ${TAG_NAME}"
echo "Release: ${RELEASE_NAME}"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry run: tag exists = ${tag_exists}"
  echo "Dry run: release exists = ${release_exists}"

  if [[ "$tag_exists" == "false" ]]; then
    echo "Dry run: would create tag ${TAG_NAME}"
  fi

  if [[ "$release_exists" == "false" ]]; then
    echo "Dry run: would build site and create release ${RELEASE_NAME}"
  fi

  exit 0
fi

if [[ "$tag_exists" == "false" ]]; then
  echo "Creating missing tag: ${TAG_NAME}"

  git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
  git push origin "$TAG_NAME"
fi

if [[ "$release_exists" == "false" ]]; then
  echo "Creating missing release: ${RELEASE_NAME}"

  ./scripts/astro/build.sh
  ./scripts/release/package-site.sh --version "$VERSION"

  gh release create "$TAG_NAME" "${ROOT_DIR}/${ARCHIVE_NAME}" \
    --title "$RELEASE_NAME" \
    --notes "Release ${RELEASE_NAME}"
fi

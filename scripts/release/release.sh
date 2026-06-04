#!/usr/bin/env bash
set -euo pipefail

##############################################################
# Orchestrate version bump, packaging, tagging, and release. #
##############################################################

DRY_RUN=false
MODE=""
BASE_BRANCH="main"

usage() {
  cat <<EOF
Usage:
  $0 [--dry-run] <pr|release> [--base-branch <branch>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  pr | release)
    MODE="$1"
    shift
    ;;
  -b | --base-branch)
    BASE_BRANCH="${2:-main}"
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "[ERROR] Unknown arg: $1" >&2
    usage
    exit 1
    ;;
  esac
done

if [[ -z "$MODE" ]]; then
  usage
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if [[ "$MODE" == "release" && "$DRY_RUN" == false ]]; then
  HEAD_MSG="$(git log -1 --pretty=%B)"
  if grep -q '\[release skip\]' <<<"$HEAD_MSG"; then
    echo "Release commit detected; skipping release workflow."
    exit 0
  fi
fi

BUMPTYPE="$(./scripts/versioning/detect-bump.sh "$BASE_BRANCH" || true)"
if [[ -z "$BUMPTYPE" ]]; then
  echo "No version bump required"
  exit 0
fi

echo "Detected bump type: $BUMPTYPE"

if [[ "$MODE" == "pr" ]]; then
  echo "PR mode: running Astro build only"
  ./scripts/astro/build.sh
  exit 0
fi

CURRENT_VERSION="$(<VERSION)"
NEXT_VERSION="$(./scripts/versioning/bump-version.sh -b "$BUMPTYPE" --print-next-version)"

if $DRY_RUN; then
  echo "Dry run preview:"
  echo "  Current VERSION: ${CURRENT_VERSION}"
  echo "  Next VERSION:    ${NEXT_VERSION}"
  echo "  Archive name:    site-v${CURRENT_VERSION}.tar.gz"
  echo "  No commit, tag, or release will be created."

  ./scripts/versioning/bump-version.sh -b "$BUMPTYPE" --dry-run
  ./scripts/astro/build.sh
  ./scripts/release/package-site.sh --dry-run --version "$CURRENT_VERSION"
  ./scripts/release/create-release.sh --dry-run --version "$CURRENT_VERSION"
  echo "Dry run: skipping commit, tag, push, and upload"
  exit 0
fi

./scripts/versioning/bump-version.sh -b "$BUMPTYPE"
VERSION="$(<VERSION)"
TAG_NAME="v${VERSION}"

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add VERSION
git commit -m "chore(release): bump version to ${VERSION} [release skip]"

git push origin HEAD:main
git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
git push origin "$TAG_NAME"

./scripts/astro/build.sh
./scripts/release/package-site.sh --version "$VERSION"
./scripts/release/create-release.sh --version "$VERSION"

#!/usr/bin/env bash
set -euo pipefail

##############################################################
# Orchestrate version bump, packaging, tagging, and release. #
##############################################################

MODE="${1:-}"
BASE_BRANCH="${2:-main}"

if [[ -z "$MODE" ]]; then
  echo "Usage: $0 <pr|release> [base-branch]" >&2
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if [[ "$MODE" == "release" ]]; then
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
  echo "PR mode: running test build only"
  ./scripts/build-site.sh
  exit 0
fi

if [[ "$MODE" != "release" ]]; then
  echo "Usage: $0 <pr|release> [base-branch]" >&2
  exit 1
fi

./scripts/versioning/bump-version.sh --bump-type "$BUMPTYPE"

VERSION="$(<VERSION)"
ARCHIVE_NAME="site-v${VERSION}.tar.gz"

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add VERSION
git commit -m "chore(release): bump version to ${VERSION} [release skip]"
git tag -a "v${VERSION}" -m "Release v${VERSION}"
git push origin HEAD:main
git push origin "v${VERSION}"

./scripts/release/package-site.sh
./scripts/release/create-release.sh

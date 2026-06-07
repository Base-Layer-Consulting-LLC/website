#!/usr/bin/env bash
set -euo pipefail

############################################################
# Orchestrate version bump, build, packaging, and release. #
############################################################

DRY_RUN=false
MODE=""
BASE_BRANCH="main"
BEFORE_SHA=""
AFTER_SHA=""

function usage() {
  cat <<EOF
Usage:
  $0 [--dry-run] <pr|release> [--base-branch <branch>] [--before-sha <sha>] [--after-sha <sha>]
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
  --before-sha)
    BEFORE_SHA="${2:-}"
    shift 2
    ;;
  --after-sha)
    AFTER_SHA="${2:-}"
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

if [[ -z "$MODE" ]]; then
  usage
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

## Default outputs
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "released=false" >>"$GITHUB_OUTPUT"
fi

## Skip logic for release commits
if [[ "$MODE" == "release" && "$DRY_RUN" == false ]]; then
  HEAD_MSG="$(git log -1 --pretty=%B)"
  if grep -q '\[release skip\]' <<<"$HEAD_MSG"; then
    echo "Release commit detected; skipping release workflow."
    exit 0
  fi
fi

if [[ -n "$BEFORE_SHA" && -n "$AFTER_SHA" ]]; then
  if git diff --quiet "$BEFORE_SHA" "$AFTER_SHA" -- site/; then
    echo "No version bump required"
    exit 0
  fi
fi

BUMPTYPE="$(./scripts/versioning/detect-bump.sh "$BASE_BRANCH")"

if [[ -z "$BUMPTYPE" ]]; then
  echo "No version bump required"
  exit 0
fi

echo "Detected bump type: $BUMPTYPE"

## PR mode
if [[ "$MODE" == "pr" ]]; then
  echo "PR mode: building site only"
  npm ci --prefix site
  (cd site && npm run build)
  test -f site/dist/index.html
  echo "Build OK"
  exit 0
fi

## Dry run
CURRENT_VERSION="$(<VERSION)"
NEXT_VERSION="$(./scripts/versioning/bump-version.sh -b "$BUMPTYPE" --print-next-version)"

if $DRY_RUN; then
  echo "Dry run:"
  echo "  Current: $CURRENT_VERSION"
  echo "  Next:    $NEXT_VERSION"

  ./scripts/versioning/bump-version.sh -b "$BUMPTYPE" --dry-run

  npm ci --prefix site
  (cd site && npm run build)

  test -f site/dist/index.html

  ./scripts/release/package-site.sh --dry-run --version "$CURRENT_VERSION"
  ./scripts/release/create-release.sh --dry-run --version "$CURRENT_VERSION"

  exit 0
fi

## Real release

./scripts/versioning/bump-version.sh -b "$BUMPTYPE"
VERSION="$(<VERSION)"
TAG_NAME="v${VERSION}"

echo "Releasing $TAG_NAME"

## Build site
(cd site && npm run build)

## Validate build output
if [[ ! -f site/dist/index.html ]]; then
  echo "[ERROR] Astro build output missing" >&2
  exit 1
fi

## Git commit + tag
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add VERSION
git commit -m "chore(release): bump version to ${VERSION} [release skip]"

git push origin HEAD:main
git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
git push origin "$TAG_NAME"

## Package + publish
./scripts/release/package-site.sh --version "$VERSION"
./scripts/release/create-release.sh --version "$VERSION"

## Export release metadata
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "released=true"
    echo "version=$VERSION"
  } >>"$GITHUB_OUTPUT"
fi

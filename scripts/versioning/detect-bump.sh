#!/usr/bin/env bash
set -euo pipefail

############################################################
# Detect changes in the site/ directory & return bump type #
############################################################

BASE_BRANCH="${1:-main}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

## Find the most recent commit shared with the base branch.
if git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null; then
  BASE_REF="$BASE_BRANCH"
elif git rev-parse --verify --quiet "origin/$BASE_BRANCH" >/dev/null; then
  BASE_REF="origin/$BASE_BRANCH"
else
  echo "[ERROR] Unable to resolve base branch: $BASE_BRANCH" >&2
  exit 1
fi

BASE_REF="$(git merge-base "$BASE_REF" HEAD)"

## Exit if nothing in site/ changed between the base branch and HEAD.
if git diff --quiet "$BASE_REF" HEAD -- site/; then
  exit 0
fi

## Get commit subjects and bodies for the current branch only.
SUBJECTS="$(git log --format=%s "$BASE_REF..HEAD")"
BODIES="$(git log --format=%B "$BASE_REF..HEAD")"

## No commits affecting the current branch since the base branch
if [[ -z "$SUBJECTS" ]]; then
  exit 0
fi

## Major:
#   feat!: ...
#   fix!: ...
#   feat(scope)!: ...
#   BREAKING CHANGE: ...
if grep -q 'BREAKING CHANGE' <<<"$BODIES" ||
  grep -Eq '^[a-z]+(\([^)]+\))?!:' <<<"$SUBJECTS"; then
  echo "major"

## Minor:
#   feat: ...
#   feat(scope): ...
elif grep -Eq '^feat(\([^)]+\))?:' <<<"$SUBJECTS"; then
  echo "minor"

## Patch:
#   fix: ...
#   fix(scope): ...
elif grep -Eq '^fix(\([^)]+\))?:' <<<"$SUBJECTS"; then
  echo "patch"
fi

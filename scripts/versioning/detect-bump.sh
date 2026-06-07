#!/usr/bin/env bash
set -euo pipefail

############################################################
# Detect changes in the site/ directory & return bump type #
############################################################

BASE_BRANCH="${1:-main}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

## Resolve the base branch ref, preferring a local branch and then origin/*.
#  This lets the script work in both local checkouts and CI clones.
if git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null; then
  BASE_REF="$BASE_BRANCH"
elif git rev-parse --verify --quiet "origin/$BASE_BRANCH" >/dev/null; then
  BASE_REF="origin/$BASE_BRANCH"
else
  echo "[ERROR] Unable to resolve base branch: $BASE_BRANCH" >&2
  exit 1
fi

## Compare the current branch against its merge-base with the base branch.
#  This ignores unrelated history on the base branch and only inspects commits
#  that are unique to the current branch.
BASE_REF="$(git merge-base "$BASE_REF" HEAD)"

## If nothing changed in the site/ dir, no bump is needed
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

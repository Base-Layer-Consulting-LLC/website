#!/usr/bin/env bash
set -euo pipefail

############################################################
# Detect changes in the site/ directory & return bump type #
############################################################

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

## Find the most recent tag. If none exists, use the first commit.
BASE_REF="$(git describe --tags --abbrev=0 2>/dev/null || true)"
if [[ -z "$BASE_REF" ]]; then
  BASE_REF="$(git rev-list --max-parents=0 HEAD)"
fi

## Get commit subjects and bodies that touched site/
SUBJECTS="$(git log --format=%s "${BASE_REF}..HEAD" -- site/)"
BODIES="$(git log --format=%B "${BASE_REF}..HEAD" -- site/)"

## No commits affecting site/ since BASE_REF
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

#!/usr/bin/env bash
set -euo pipefail

############################################################
# Detect changes in the site/ directory & return bump type #
############################################################

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if git diff --quiet HEAD -- site/; then
  exit 0
fi

BASE_REF="$(git describe --tags --abbrev=0 2>/dev/null || echo '')"
if [[ -z "$BASE_REF" ]]; then
  BASE_REF="$(git rev-list --max-parents=0 HEAD)"
fi

COMMITS="$(git log --format=%B "${BASE_REF}..HEAD" -- site/)"

if grep -Eq 'BREAKING CHANGE|!:' <<<"$COMMITS"; then
  echo "major"
elif grep -Eq '^feat(\(.+\))?:' <<<"$COMMITS"; then
  echo "minor"
elif grep -Eq '^fix(\(.+\))?:' <<<"$COMMITS"; then
  echo "patch"
fi

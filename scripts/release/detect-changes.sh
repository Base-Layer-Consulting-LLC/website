#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${1:-main}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null; then
  BASE_REF="$BASE_BRANCH"
elif git rev-parse --verify --quiet "origin/$BASE_BRANCH" >/dev/null; then
  BASE_REF="origin/$BASE_BRANCH"
else
  echo "[ERROR] Unable to resolve base branch: $BASE_BRANCH" >&2
  exit 1
fi

MERGE_BASE="$(git merge-base "$BASE_REF" HEAD)"

if git diff --quiet "$MERGE_BASE" HEAD -- site/; then
  echo "changed=false"
else
  echo "changed=true"
fi

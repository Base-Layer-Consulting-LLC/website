#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${1:-main}"
FROM_SHA="${2:-}"
TO_SHA="${3:-}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if [[ -n "$FROM_SHA" && -n "$TO_SHA" ]]; then
  if git diff --quiet "$FROM_SHA" "$TO_SHA" -- site/; then
    echo "changed=false"
  else
    echo "changed=true"
  fi
  exit 0
fi

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

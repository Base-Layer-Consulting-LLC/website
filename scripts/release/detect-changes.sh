#!/usr/bin/env bash
set -euo pipefail

##########################################################
# Detect changes in recent git history to determine      #
# if a version bump/release should happen.               #
#                                                        #
# Uses a "from" and "to" SHA to set the range to search. #
##########################################################

BASE_BRANCH="${1:-main}"
FROM_SHA="${2:-}"
TO_SHA="${3:-}"

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

## Compare range of commits between 2 SHAs. Determine if
#  any files in the site/ dir changed in that range.
if [[ -n "$FROM_SHA" && -n "$TO_SHA" ]]; then
  if git diff --quiet "$FROM_SHA" "$TO_SHA" -- site/; then
    echo "changed=false"
  else
    echo "changed=true"
  fi
  exit 0
fi

## Resolve the base branch ref, preferring a local branch first
#  and falling back to origin/<branch> when local is unavailable.
if git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null; then
  BASE_REF="$BASE_BRANCH"
elif git rev-parse --verify --quiet "origin/$BASE_BRANCH" >/dev/null; then
  BASE_REF="origin/$BASE_BRANCH"
else
  echo "[ERROR] Unable to resolve base branch: $BASE_BRANCH" >&2
  exit 1
fi

## Find the latest common ancestor of the base branch & current branch.
#  Helps to avoid redeploying on changes that are already deployed.
MERGE_BASE="$(git merge-base "$BASE_REF" HEAD)"

## Report changes to the caller (pipeline, shell)
if git diff --quiet "$MERGE_BASE" HEAD -- site/; then
  echo "changed=false"
else
  echo "changed=true"
fi

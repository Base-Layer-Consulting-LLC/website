#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${1:-main}"
ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

CHANGED=false
VERSION_CHANGED=false

if git diff --name-only "origin/${BASE_BRANCH}...HEAD" | grep -qE '^\.containers/ci/'; then
  CHANGED=true
fi

if git diff --name-only "origin/${BASE_BRANCH}...HEAD" | grep -qE '^\.containers/ci/VERSION$'; then
  VERSION_CHANGED=true
fi

if [[ "${GITHUB_EVENT_NAME:-}" == "pull_request" ]]; then
  COUNT="$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" | grep -cE '^\.containers/ci/VERSION$' || true)"
  if [[ "$COUNT" -gt 1 ]]; then
    echo "[ERROR] VERSION bumped more than once in this PR" >&2
    exit 1
  fi
fi

VERSION="$(<.containers/ci/VERSION)"

echo "changed=$CHANGED"
echo "version=$VERSION"
echo "version_changed=$VERSION_CHANGED"

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
bump-my-version bump "$@" \
  --config-file "$ROOT_DIR/.containers/ci/.bumpversion.toml"

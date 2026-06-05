#!/usr/bin/env bash
set -euo pipefail

if command -v wrangler >/dev/null 2>&1; then
  echo "wrangler already installed"
  exit 0
fi

if ! command -v npm >&/dev/null; then
  echo "[ERROR] npm is not installed" >&2
  exit 1
fi

npm install -g wrangler

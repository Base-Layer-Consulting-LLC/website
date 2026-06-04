#!/usr/bin/env bash
set -euo pipefail

############################################
# Bump a version file with bump-my-version #
############################################

DRY_RUN=false
BUMP_TYPE=""

function usage() {
  cat <<EOF
Usage:
  ${0} [OPTIONS]

Options:
  -b, --bump-type   Bump type: major, minor, patch
  --dry-run         Show what would happen without changing files
  -h, --help        Show this help menu
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -b | --bump-type)
    BUMP_TYPE="${2:-}"
    shift 2
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "[ERROR] Invalid arg: $1" >&2
    usage
    exit 1
    ;;
  esac
done

if [[ -z "$BUMP_TYPE" ]]; then
  echo "[ERROR] --bump-type is required" >&2
  usage
  exit 1
fi

case "$BUMP_TYPE" in
major | minor | patch) ;;
*)
  echo "[ERROR] Invalid bump type: $BUMP_TYPE" >&2
  exit 1
  ;;
esac

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR/site"

cmd=(bump-my-version bump "$BUMP_TYPE")

if $DRY_RUN; then
  cmd+=(--dry-run)
fi

"${cmd[@]}"

#!/usr/bin/env bash
set -euo pipefail

############################################
# Bump a version file with bump-my-version #
############################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR=$(realpath -m "${THIS_DIR}/../..")

CURRENT_VERSION="$(<VERSION)"
DRY_RUN=false
BUMP_TYPE=""
CWD="$(pwd)"

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

function cleanup() {
  cd "${CWD}"
}
trap cleanup EXIT

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

cd "$ROOT_DIR/site"

if $DRY_RUN; then
  if NEXT_VERSION="$(bump-my-version show --current-version "$CURRENT_VERSION" --increment "$BUMP_TYPE" new_version 2>/dev/null)"; then
    echo "Would bump VERSION from $CURRENT_VERSION to $NEXT_VERSION"
  else
    echo "No version was bumped"
  fi
  exit 0
fi

cmd=(bump-my-version bump --current-version "$CURRENT_VERSION" "$BUMP_TYPE")
"${cmd[@]}"

#!/usr/bin/env bash
set -euo pipefail

############################################
# Bump a version file with bump-my-version #
############################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(realpath -m "${THIS_DIR}/../..")"

CURRENT_VERSION="$(<"${ROOT_DIR}/VERSION")"
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

IFS='.' read -r major minor patch <<<"$CURRENT_VERSION"
case "$BUMP_TYPE" in
major)
  major=$((major + 1))
  minor=0
  patch=0
  ;;
minor)
  minor=$((minor + 1))
  patch=0
  ;;
patch)
  patch=$((patch + 1))
  ;;
esac
NEXT_VERSION="${major}.${minor}.${patch}"

if $DRY_RUN; then
  echo "Would bump VERSION from $CURRENT_VERSION to $NEXT_VERSION"
  exit 0
fi

echo "$NEXT_VERSION" >"${ROOT_DIR}/VERSION"
echo "Bumped VERSION from $CURRENT_VERSION to $NEXT_VERSION"

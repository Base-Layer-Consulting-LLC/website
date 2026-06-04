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
  $0 --bump-type <major|minor|patch> [--dry-run]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --bump-type | -b)
    BUMP_TYPE="${2:-}"
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "[ERROR] Unknown arg: $1" >&2
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

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT_DIR="$(realpath -m "${THIS_DIR}/../..")"
CURRENT_VERSION="$(<"${ROOT_DIR}/VERSION")"

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
patch) patch=$((patch + 1)) ;;
*)
  echo "[ERROR] Invalid bump type: $BUMP_TYPE" >&2
  exit 1
  ;;
esac

NEXT_VERSION="${major}.${minor}.${patch}"

if $DRY_RUN; then
  echo "Would bump VERSION from ${CURRENT_VERSION} to ${NEXT_VERSION}"
  exit 0
fi

echo "$NEXT_VERSION" >"${ROOT_DIR}/VERSION"
echo "Bumped VERSION from ${CURRENT_VERSION} to ${NEXT_VERSION}"

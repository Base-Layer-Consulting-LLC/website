#!/usr/bin/env bash
set -euo pipefail

############################################
# Bump version files with bump-my-version  #
############################################

DRY_RUN=false
PRINT_NEXT_VERSION=false
BUMP_TYPE=""
ROOT_DIR="$(git rev-parse --show-toplevel)"

function usage() {
  cat <<EOF
Usage:
  $0 -b <major|minor|patch> [--dry-run] [--print-next-version]
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
  --print-next-version)
    PRINT_NEXT_VERSION=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "[ERROR] Unknown arg: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if [[ -z "$BUMP_TYPE" ]]; then
  echo "[ERROR] Missing bump type" >&2
  usage
  exit 1
fi

cd "$ROOT_DIR"

CURRENT_VERSION="$(<VERSION)"

IFS=. read -r major minor patch <<<"$CURRENT_VERSION"
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
*)
  echo "[ERROR] Invalid bump type: $BUMP_TYPE" >&2
  exit 1
  ;;
esac

NEXT_VERSION="${major}.${minor}.${patch}"

if $PRINT_NEXT_VERSION; then
  echo "$NEXT_VERSION"
  exit 0
fi

if $DRY_RUN; then
  echo "Would bump VERSION from ${CURRENT_VERSION} to ${NEXT_VERSION}"
  echo "Would update .bumpversion.toml current_version to ${NEXT_VERSION}"
  exit 0
fi

echo "$NEXT_VERSION" >"${ROOT_DIR}/VERSION"

if [[ -f "${ROOT_DIR}/.bumpversion.toml" ]]; then
  if grep -q "^current_version = \"${CURRENT_VERSION}\"$" "${ROOT_DIR}/.bumpversion.toml"; then
    sed -i "s/^current_version = \"${CURRENT_VERSION}\"$/current_version = \"${NEXT_VERSION}\"/" "${ROOT_DIR}/.bumpversion.toml"
  else
    echo "[ERROR] .bumpversion.toml current_version line not found or unexpected format" >&2
    exit 1
  fi
fi

echo "Bumped VERSION from ${CURRENT_VERSION} to ${NEXT_VERSION}"

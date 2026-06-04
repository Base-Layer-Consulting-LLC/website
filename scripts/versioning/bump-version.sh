#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false

function usage() {
  cat <<EOF
Usage:
  ${0} [OPTIONS]

Options:
  -h, --help    Show this help menu
  --dry-run     Show the version bump that would happen, without actually bumping
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
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

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR/site"

if ! git diff --quiet HEAD -- .; then
  :
else
  echo "No changes under site/, skipping bump"
  exit 0
fi

BASE_REF="$(git describe --tags --abbrev=0 2>/dev/null || echo '')"
if [[ -z "$BASE_REF" ]]; then
  BASE_REF="$(git rev-list --max-parents=0 HEAD)"
fi

COMMITS="$(git log --format=%B "${BASE_REF}..HEAD")"

if grep -Eq 'BREAKING CHANGE|!:' <<<"$COMMITS"; then
  PART="major"
elif grep -Eq '^feat(\(.+\))?:' <<<"$COMMITS"; then
  PART="minor"
elif grep -Eq '^fix(\(.+\))?:' <<<"$COMMITS"; then
  PART="patch"
else
  echo "No conventional bump-worthy commits found since $BASE_REF"
  exit 0
fi

echo "Next bump: $PART"
echo

cmd=(bump-my-version bump "$PART")

if $DRY_RUN; then
  cmd+=(--dry-run)
fi

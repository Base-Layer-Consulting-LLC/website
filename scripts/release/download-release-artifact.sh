#!/usr/bin/env bash
set -euo pipefail

#####################################################
# Download a release artifact from Github releases  #
#                                                   #
# Downloads the latest release artifact by default, #
# or you can pass a specific tag.                   #
#####################################################

VERSION=""
TAG_NAME=""
ASSET_NAME=""
OUTPUT_DIR=""

function usage() {
  cat <<EOF
Usage:
  $0 [--version <version>] [--tag <tag>] [--asset <asset-name>] [--output-dir <dir>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --version)
    VERSION="${2:-}"
    shift 2
    ;;
  --tag)
    TAG_NAME="${2:-}"
    shift 2
    ;;
  --asset)
    ASSET_NAME="${2:-}"
    shift 2
    ;;
  --output-dir)
    OUTPUT_DIR="${2:-}"
    shift 2
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

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if [[ -z "$VERSION" && -z "$TAG_NAME" ]]; then
  VERSION="$(<VERSION)"
fi

if [[ -z "$TAG_NAME" ]]; then
  TAG_NAME="v${VERSION}"
fi

if [[ -z "$VERSION" ]]; then
  VERSION="${TAG_NAME#v}"
fi

if [[ -z "$ASSET_NAME" ]]; then
  ASSET_NAME="site-${TAG_NAME}.tar.gz"
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$(mktemp -d)"
fi

mkdir -p "$OUTPUT_DIR"

gh release download "$TAG_NAME" --pattern "$ASSET_NAME" --dir "$OUTPUT_DIR"

echo "$OUTPUT_DIR/$ASSET_NAME"

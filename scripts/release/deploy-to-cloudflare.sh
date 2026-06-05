#!/usr/bin/env bash
set -euo pipefail

########################################################################
# Download latest github release asset and deploy to Cloudflare Pages. #
########################################################################

DRY_RUN=false
FORCE=false
VERSION=""
TAG_NAME=""
ASSET_NAME=""

function usage() {
  cat <<EOF
Usage:
  $0 [--dry-run] [--force] [--version <version>] [--tag <tag>] [--asset <asset-name>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --force)
    FORCE=true
    shift
    ;;
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

if $FORCE; then
  if $DRY_RUN; then
    echo "Dry run: would run npm ci in site/"
    echo "Dry run: would build site"
    echo "Dry run: would deploy site/dist to Cloudflare Pages"
    exit 0
  fi

  npm ci --prefix site
  (cd site && npm run build)
  npx wrangler pages deploy "site/dist" --project-name "$CLOUDFLARE_PAGES_PROJECT_PROD"
  exit 0
fi

DOWNLOAD_DIR="$(mktemp -d)"
EXTRACT_DIR="$(mktemp -d)"
trap 'rm -rf "$DOWNLOAD_DIR" "$EXTRACT_DIR"' EXIT

ARGS=()
if [[ -n "$VERSION" ]]; then
  ARGS+=(--version "$VERSION")
fi
if [[ -n "$TAG_NAME" ]]; then
  ARGS+=(--tag "$TAG_NAME")
fi
if [[ -n "$ASSET_NAME" ]]; then
  ARGS+=(--asset "$ASSET_NAME")
fi

ARTIFACT_PATH="$(./scripts/release/download-release-artifact.sh "${ARGS[@]}" --output-dir "$DOWNLOAD_DIR")"

tar -xzf "$ARTIFACT_PATH" -C "$EXTRACT_DIR"

DEPLOY_DIR="$EXTRACT_DIR/site"
if [[ ! -d "$DEPLOY_DIR" ]]; then
  DEPLOY_DIR="$EXTRACT_DIR"
fi

if [[ ! -d "$DEPLOY_DIR" ]]; then
  echo "[ERROR] Deploy directory not found: $DEPLOY_DIR" >&2
  exit 1
fi

if $DRY_RUN; then
  echo "Dry run: would deploy $DEPLOY_DIR to Cloudflare Pages"
  exit 0
fi

npx wrangler pages deploy "$DEPLOY_DIR" --project-name "$CLOUDFLARE_PAGES_PROJECT_PROD"

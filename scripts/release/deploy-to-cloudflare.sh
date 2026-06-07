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

## Skip downloading release asset, rebuild the site and deploy
#  that instead. While not best practice, this is an avenue
#  to force push a change quickly, sidestepping the release process.
if $FORCE; then
  if $DRY_RUN; then
    echo "Dry run: would run npm ci in site/"
    echo "Dry run: would build site"
    echo "Dry run: would deploy site/dist/client to Cloudflare Pages"
    exit 0
  fi

  ## Rebuild and deploy site
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

## Download release artifact from Github and output path to variable
ARTIFACT_PATH="$(./scripts/release/download-release-artifact.sh "${ARGS[@]}" --output-dir "$DOWNLOAD_DIR")"

## Extract downloaded release
tar -xzf "$ARTIFACT_PATH" -C "$EXTRACT_DIR"

## Find index.html to set the directory path that should be deployed.
#  This might be the root of the archive, or a subdirectory like site/.
DEPLOY_DIR=""
if [[ -f "$EXTRACT_DIR/index.html" ]]; then
  DEPLOY_DIR="$EXTRACT_DIR"
else
  echo "[ERROR] No deployable directory found in extracted asset" >&2
  exit 1
fi

if [[ -z "$DEPLOY_DIR" ]]; then
  echo "[ERROR] No deployable directory found in extracted asset" >&2
  exit 1
fi

if $DRY_RUN; then
  echo "Dry run: would deploy $DEPLOY_DIR to Cloudflare Pages"
  exit 0
fi

## Deploy to Cloudflare Pages
npx wrangler pages deploy "$DEPLOY_DIR" --project-name "$CLOUDFLARE_PAGES_PROJECT_PROD"

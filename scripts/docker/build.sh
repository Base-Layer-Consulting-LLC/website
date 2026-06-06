#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-}"

if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image>"
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"

case "$IMAGE" in
ci)
  CONTEXT="$ROOT_DIR"
  DOCKERFILE="$ROOT_DIR/.containers/ci/Dockerfile"
  TAG="ci:local"
  ;;
*)
  echo "[ERROR] Unknown image: $IMAGE" >&2
  exit 1
  ;;
esac

docker build \
  -f "$DOCKERFILE" \
  -t "$TAG" \
  "$CONTEXT"

#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ci}"

ROOT_DIR="$(git rev-parse --show-toplevel)"

REGISTRY="${REGISTRY:-ghcr.io}"

VERSION="$(
  <"$ROOT_DIR/.containers/${IMAGE}/VERSION"
)"

case "$REGISTRY" in
ghcr.io)
  IMAGE_NAME="${REGISTRY}/${GITHUB_REPOSITORY}/${IMAGE}:${VERSION}"
  ;;
*)
  echo "Unsupported registry"
  exit 1
  ;;
esac

./scripts/docker/build.sh "$IMAGE"

echo "$GH_TOKEN" |
  docker login ghcr.io \
    -u "${GITHUB_ACTOR}" \
    --password-stdin

docker tag "${IMAGE}:local" "$IMAGE_NAME"

docker push "$IMAGE_NAME"

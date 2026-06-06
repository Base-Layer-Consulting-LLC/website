#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ci}"
ROOT_DIR="$(git rev-parse --show-toplevel)"
VERSION="$(<"$ROOT_DIR/.containers/${IMAGE}/VERSION")"
REGISTRY="${REGISTRY:-ghcr.io}"

case "$REGISTRY" in
ghcr.io)
  IMAGE_NAME="${REGISTRY}/${GITHUB_REPOSITORY}/${IMAGE}"
  ;;
*)
  echo "Unsupported registry" >&2
  exit 1
  ;;
esac

./scripts/docker/build.sh "$IMAGE"

echo "$GH_TOKEN" | docker login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin

docker tag "${IMAGE}:local" "${IMAGE_NAME}:${VERSION}"
docker tag "${IMAGE}:local" "${IMAGE_NAME}:latest"
docker push "${IMAGE_NAME}:${VERSION}"
docker push "${IMAGE_NAME}:latest"

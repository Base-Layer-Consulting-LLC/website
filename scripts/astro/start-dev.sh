#!/usr/bin/env bash

THIS_DIR="$(dirname "${0}")"
REPO_ROOT=$(realpath -m "${THIS_DIR}/../..")
ASTRO_ROOT="${REPO_ROOT}/site"
CWD="$(pwd)"

HOST="${ASTRO_HOST:-localhost}"
PORT="${ASTRO_PORT:-4321}"
PROTO="${ASTRO_PROTO:-http}"

if ! command -v npm &>/dev/null; then
  echo "[ERROR] npm is not installed." >&2
  exit 1
fi

function usage() {
  echo ""
  echo "Usage: ${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help menu"
  echo "  -H, --host    Host address to serve on. Default: localhost.  Use --host 0.0.0.0 to serve on all interfaces"
  echo "  -p, --port    Port to serve site on. Default: 4321"
  echo "  -P, --proto   http (default) or https"
  echo "  -s, --site    Address or URL site is served on. Default: \$PROTO://\$HOST:\$PORT (http://localhost:4321)"
  echo ""
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -H | --host)
    HOST="${2}"
    shift 2
    ;;
  -p | --port)
    PORT="${2}"
    shift 2
    ;;
  -P | --proto)
    PROTO="${2}"
    shift 2
    ;;
  *)
    echo "[ERROR] Invalid arg: $1" >&2
    exit 1
    ;;
  esac
done

if [[ -z "$HOST" ]]; then
  echo "[ERROR] --host value cannot be empty" >&2
  exit 1
fi

if [[ -z "$PORT" ]]; then
  echo "[ERROR] --port value cannot be empty" >&2
  exit 1
fi

case "${PROTO}" in
http | https)
  SITE_ADDR="${PROTO}://${HOST}:${PORT}"
  ;;
*)
  echo "[ERROR] --proto must be one of 'http' or 'https'. Got: ${PROTO}" >&2
  exit 1
  ;;
esac

function cleanup() {
  cd "${CWD}" || true
}
trap cleanup EXIT

echo "Starting Astro dev server"
echo "  Serving on: ${SITE_ADDR}"
echo ""

cd "${ASTRO_ROOT}" || true

if ! npm run dev -- --host "${HOST}" --port "${PORT}" --site "${SITE_ADDR}" 2>&1; then
  echo ""
  echo "[ERROR] Astro dev server failed" >&2
  exit 1
fi

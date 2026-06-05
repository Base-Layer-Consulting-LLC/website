#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "${THIS_DIR}/_common.sh"

if has_cmd node; then
  echo "node already installed"
  exit 0
fi

function as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

id="$(detect_os_id)"

case "$id" in
ubuntu | debian)
  as_root apt-get update
  as_root apt-get install -y nodejs npm
  ;;
fedora)
  as_root dnf install -y nodejs npm
  ;;
rhel | centos | rocky | almalinux)
  if has_cmd dnf; then
    as_root dnf install -y nodejs npm
  else
    as_root yum install -y nodejs npm
  fi
  ;;
arch | manjaro)
  as_root pacman -Sy --noconfirm nodejs npm
  ;;
alpine)
  as_root apk add nodejs npm
  ;;
*)
  echo "[ERROR] Unsupported Linux distro for node install: $id" >&2
  exit 1
  ;;
esac

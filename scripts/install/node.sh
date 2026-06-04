#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "${THIS_DIR}/_common.sh"

if has_cmd node; then
  echo "node already installed"
  exit 0
fi

id="$(detect_os_id)"

case "$id" in
ubuntu | debian)
  sudo apt-get update
  sudo apt-get install -y nodejs npm
  ;;
fedora)
  sudo dnf install -y nodejs npm
  ;;
rhel | centos | rocky | almalinux)
  if has_cmd dnf; then
    sudo dnf install -y nodejs npm
  else
    sudo yum install -y nodejs npm
  fi
  ;;
arch | manjaro)
  sudo pacman -Sy --noconfirm nodejs npm
  ;;
alpine)
  sudo apk add nodejs npm
  ;;
*)
  echo "[ERROR] Unsupported Linux distro for node install: $id" >&2
  exit 1
  ;;
esac

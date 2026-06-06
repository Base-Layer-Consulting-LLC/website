#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "${THIS_DIR}/_common.sh"

if has_cmd bump-my-version; then
  echo "bump-my-version already installed"
  exit 0
fi

echo "Installing bump-my-version"

id="$(detect_os_id)"

case "$id" in
ubuntu | debian)
  if ! has_cmd python3; then
    install_cmd python3
  fi

  if ! has_cmd python3-venv; then
    sudo apt-get update
    sudo apt-get install -y python3-venv
  fi

  python3 -m venv /opt/bump-my-version-venv

  /opt/bump-my-version-venv/bin/pip install --upgrade pip
  /opt/bump-my-version-venv/bin/pip install bump-my-version

  ln -sf /opt/bump-my-version-venv/bin/bump-my-version /usr/local/bin/bump-my-version
  ;;
fedora | rhel | centos | rocky | almalinux | arch | manjaro | alpine)
  if ! has_cmd python3; then
    install_cmd python3
  fi
  python3 -m venv /opt/bump-my-version-venv
  /opt/bump-my-version-venv/bin/pip install --upgrade pip
  /opt/bump-my-version-venv/bin/pip install bump-my-version
  ln -sf /opt/bump-my-version-venv/bin/bump-my-version /usr/local/bin/bump-my-version
  ;;
*)
  echo "[ERROR] Unsupported Linux distro for bump-my-version install: $id" >&2
  exit 1
  ;;
esac

echo "bump-my-version installed"

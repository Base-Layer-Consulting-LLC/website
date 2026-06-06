#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "${THIS_DIR}/_common.sh"

if has_cmd gh; then
  echo "gh already installed"
  exit 0
fi

echo "Installing gh..."

id="$(detect_os_id)"

case "$id" in
ubuntu | debian)
  if ! has_cmd curl; then
    install_cmd curl
  fi
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo mkdir -p -m 755 /etc/apt/sources.list.d
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y gh
  ;;
fedora)
  sudo dnf install -y 'dnf-command(config-manager)'
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh --repo gh-cli
  ;;
rhel | centos | rocky | almalinux)
  if has_cmd dnf; then
    sudo dnf install -y 'dnf-command(config-manager)'
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install -y gh --repo gh-cli
  else
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    sudo yum install -y gh
  fi
  ;;
arch | manjaro)
  sudo pacman -Sy --noconfirm github-cli
  ;;
alpine)
  apk add --no-cache github-cli
  ;;
*)
  echo "[ERROR] Unsupported Linux distro for gh install: $id" >&2
  exit 1
  ;;
esac

echo "gh installed"

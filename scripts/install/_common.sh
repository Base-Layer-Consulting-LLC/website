#!/usr/bin/env bash
set -euo pipefail

function detect_os_id() {
  [[ -f /etc/os-release ]] || return 1
  # shellcheck disable=SC1091
  source /etc/os-release
  echo "${ID:-unknown}"
}

function has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

function install_cmd() {
  local pkg="$1"
  local id
  id="$(detect_os_id)"

  case "$id" in
  ubuntu | debian)
    sudo apt-get update
    sudo apt-get install -y "$pkg"
    ;;
  fedora)
    sudo dnf install -y "$pkg"
    ;;
  rhel | centos | rocky | almalinux)
    if has_cmd dnf; then
      sudo dnf install -y "$pkg"
    else
      sudo yum install -y "$pkg"
    fi
    ;;
  arch | manjaro)
    sudo pacman -Sy --noconfirm "$pkg"
    ;;
  alpine)
    sudo apk add "$pkg"
    ;;
  *)
    echo "[ERROR] Unsupported Linux distro: $id" >&2
    return 1
    ;;
  esac
}

function python_bin() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1; then
    echo "python"
  else
    return 1
  fi
}

function install_python() {
  local id
  id="$(detect_os_id)"

  case "$id" in
  ubuntu | debian)
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
    ;;
  fedora | rhel | centos | rocky | almalinux)
    if has_cmd dnf; then
      sudo dnf install -y python3 python3-pip
    else
      sudo yum install -y python3 python3-pip
    fi
    ;;
  arch | manjaro)
    sudo pacman -Sy --noconfirm python python-pip
    ;;
  alpine)
    sudo apk add python3 py3-pip
    ;;
  *)
    echo "[ERROR] Unsupported Linux distro for python install: $id" >&2
    return 1
    ;;
  esac
}

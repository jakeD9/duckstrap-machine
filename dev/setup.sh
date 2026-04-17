#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load shared utils
source "$REPO_ROOT/utils.sh"

info "Installing dev environment tools..."

open_url_in_browser() {
  local url="$1"
  local browser_user="${SUDO_USER:-${USER:-}}"
  local browser_uid=""
  local browser_cmd=""

  if command -v sensible-browser >/dev/null 2>&1; then
    browser_cmd="sensible-browser"
  elif command -v x-www-browser >/dev/null 2>&1; then
    browser_cmd="x-www-browser"
  elif command -v xdg-open >/dev/null 2>&1; then
    browser_cmd="xdg-open"
  else
    return 1
  fi

  if [[ -n "$browser_user" ]] && [[ "$browser_user" != "root" ]]; then
    browser_uid="$(id -u "$browser_user" 2>/dev/null || true)"
    if [[ -n "$browser_uid" ]]; then
      nohup sudo -u "$browser_user" \
        env DISPLAY="${DISPLAY:-:0}" \
        XAUTHORITY="${XAUTHORITY:-/home/$browser_user/.Xauthority}" \
        XDG_RUNTIME_DIR="/run/user/$browser_uid" \
        "$browser_cmd" "$url" >/dev/null 2>&1 </dev/null &
      return 0
    fi
  fi

  nohup "$browser_cmd" "$url" >/dev/null 2>&1 </dev/null &
  return 0
}

# Core
install_packages \
  gh \
  wget \
  unzip \
  jq \
  ripgrep \
  fzf

# Editors
install neovim

# Containers
read -rp "Install Docker Desktop or Docker CLI? [desktop/cli/skip] " docker_choice

case "${docker_choice:-skip}" in
  desktop)
    case "$PM" in
      brew)
        info "Installing Docker Desktop via Homebrew"
        brew install --cask docker
        ;;
      *)
        warn "Docker Desktop automatic install is only configured here for Homebrew."

        info "Plese visit https://www.docker.com/ to download."
        ;;
    esac
    ;;
  cli)
    warn "CLI not configured yet. Sorry!"
    ;;
  skip|"")
    info "Skipping Docker installation"
    ;;
  *)
    warn "Unrecognized Docker option '$docker_choice'. Skipping Docker installation."
    ;;
esac

# Kubernetes
info "Setting up Kubernetes tools.."

case $PM in
  brew)
    brew install kubectl k9s
    ;;
  *)
    # Download kubectl to a temp file so we do not leave the binary in the repo.
    kubectl_tmp="$(mktemp)"
    curl -L -o "$kubectl_tmp" "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 "$kubectl_tmp" /usr/local/bin/kubectl
    rm -f "$kubectl_tmp"

    # k9s
    sudo snap install k9s
    ;;
esac

# Utilities
install_packages \
  htop \
  tree

success "Dev environment setup complete"

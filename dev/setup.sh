#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load shared utils
source "$REPO_ROOT/utils.sh"

info "Installing dev environment tools..."

# Core
install gh
install wget
install unzip
install jq
install ripgrep
install fzf

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
        warn "Docker Desktop install is only configured here for Homebrew. Skipping."
        ;;
    esac
    ;;
  cli)
    install docker
    install docker-compose
    ;;
  skip|"")
    info "Skipping Docker installation"
    ;;
  *)
    warn "Unrecognized Docker option '$docker_choice'. Skipping Docker installation."
    ;;
esac

# Kubernetes
install kubectl
install helm
install k9s

# Utilities
install htop
install tree

success "Dev environment setup complete"

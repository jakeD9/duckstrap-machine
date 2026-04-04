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
install docker
install docker-compose

# Kubernetes
install kubectl
install helm
install k9s

# Utilities
install tmux
install htop
install tree

success "Dev environment setup complete"
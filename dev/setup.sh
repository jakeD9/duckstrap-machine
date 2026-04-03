#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../lib/utils.sh"

info "Installing dev environment tools..."

# Core
install git
install gh
install curl
install wget
install unzip
install jq
install ripgrep
install fzf

# Editors
install neovim
install code

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
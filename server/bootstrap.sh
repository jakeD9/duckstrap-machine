#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$REPO_ROOT/utils.sh"

copy_shell_config() {
  mkdir -p "$HOME/.config"

  if prompt_yes_no "Copy repo .zshrc into your home directory?" "Y"; then
    copy_file "$REPO_ROOT/shell/zsh/.zshrc" "$HOME/.zshrc"
  fi

  if prompt_yes_no "Copy repo .p10k.zsh into your home directory?" "Y"; then
    copy_file "$REPO_ROOT/shell/p10k/.p10k.zsh" "$HOME/.p10k.zsh"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh already installed"
    return 0
  fi

  info "Installing Oh My Zsh"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_powerlevel10k() {
  local p10k_dir

  p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [[ -d "$p10k_dir" ]]; then
    success "Powerlevel10k already installed"
    return 0
  fi

  info "Installing Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
}

set_default_shell() {
  if [[ "${SHELL:-}" == "$(command -v zsh)" ]]; then
    success "Default shell already set to zsh"
    return 0
  fi

  if prompt_yes_no "Set zsh as the default shell for $(whoami)?" "Y"; then
    chsh -s "$(command -v zsh)"
    success "Default shell updated to zsh"
  else
    warn "Leaving default shell unchanged"
  fi
}

install_gh_auth() {
  install_if_missing gh

  if gh auth status >/dev/null 2>&1; then
    success "GitHub CLI already authenticated"
    return 0
  fi

  if prompt_yes_no "Authenticate GitHub CLI now?" "Y"; then
    gh auth login
  else
    warn "Skipping GitHub CLI authentication"
  fi
}

print_notes() {
  cat <<'EOF'

Baseline homelab box notes:
- This script is for making a Linux box feel like home.
- If the machine runs inside Proxmox, qemu-guest-agent is installed so the host can manage the guest cleanly.

Next step for a Kubernetes VM:
- Run ./k8s/bootstrap.sh on the VM that should become a k3s node.
EOF
}

info "Bootstrapping baseline homelab box..."

require_linux

if [[ "$PM" != "apt" ]]; then
  error "Server bootstrap currently expects Ubuntu/Debian with apt"
  exit 1
fi

info "Installing base server packages"
install_packages \
  curl \
  git \
  wget \
  unzip \
  jq \
  ripgrep \
  fzf \
  htop \
  tree \
  tmux \
  neovim \
  zsh \
  ca-certificates \
  gnupg \
  lsb-release \
  apt-transport-https \
  bash-completion \
  qemu-guest-agent

install_oh_my_zsh
install_powerlevel10k
copy_shell_config
set_default_shell
install_gh_auth

print_notes

success "Baseline homelab box bootstrap complete"

#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$REPO_ROOT/utils.sh"


info "==> Setting up Zsh environment"

#############################################
# 1. Install Zsh + dependencies
#############################################

install zsh

#############################################
# 2. Install Oh My Zsh (if missing)
#############################################

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "==> Installing Oh My Zsh"
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  warn "==> Oh My Zsh already installed"
fi

#############################################
# 3. Copy .zshrc
#############################################

read -p "Copy .zshrc from repo? [y/N] " symlink_zshrc

if [[ "$symlink_zshrc" =~ ^[Yy]$ ]]; then
  cp "$REPO_ROOT/shell/zsh/.zshrc" "$HOME/.zshrc"
  success "==> .zshrc copied"
fi

#############################################
# 4. Install Powerlevel10k (pinned)
#############################################

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
  info "==> Installing Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  warn "==> Powerlevel10k already installed"
fi

#############################################
# 5. Copy p10k config
#############################################

read -p "Copy .p10k.zsh from repo? [y/N] " symlink_p10k

if [[ "$symlink_p10k" =~ ^[Yy]$ ]]; then
  cp "$REPO_ROOT/shell/p10k/.p10k.zsh" "$HOME/.p10k.zsh"
  info "==> p10k config copied"
fi

#############################################
# 6. Install Kitty
#############################################

install_kitty() {
  case "$PM" in
    brew)
      info "==> Installing Kitty via Homebrew"
      brew install --cask kitty
      ;;
    apt)
      info "==> Installing Kitty via apt"
      sudo apt update -y >/dev/null 2>&1
      sudo apt install -y kitty
      ;;
    pacman)
      info "==> Installing Kitty via pacman"
      sudo pacman -S --noconfirm kitty
      ;;
    *)
      error "No supported package manager found for Kitty"
      return 1
      ;;
  esac
}

if ! command -v kitty >/dev/null 2>&1; then
  install_kitty
else
  echo "==> Kitty already installed"
fi

#############################################
# 7. Copy Kitty config
#############################################

mkdir -p "$HOME/.config/kitty"

read -p "Copy kitty.conf from repo? [y/N] " symlink_kitty

if [[ "$symlink_kitty" =~ ^[Yy]$ ]]; then
  cp "$REPO_ROOT/shell/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
  echo "==> kitty.conf copied"
fi

#############################################
# 8. Done
#############################################

echo "==> Zsh + Kitty setup complete"
echo "Restart your terminal to apply changes"

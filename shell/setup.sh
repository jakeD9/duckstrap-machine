#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$REPO_ROOT/utils/utils.sh"


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
# 3. Symlink .zshrc
#############################################

read -p "Symlink .zshrc from repo? [y/N] " symlink_zshrc

if [[ "$symlink_zshrc" =~ ^[Yy]$ ]]; then
  ln -sf "$REPO_ROOT/zsh/zshrc" "$HOME/.zshrc"
  success "==> .zshrc symlinked"
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
# 5. Symlink p10k config
#############################################

read -p "Symlink .p10k.zsh from repo? [y/N] " symlink_p10k

if [[ "$symlink_p10k" =~ ^[Yy]$ ]]; then
  ln -sf "$REPO_ROOT/p10k/.p10k.zsh" "$HOME/.p10k.zsh"
  info "==> p10k config symlinked"
fi

#############################################
# 6. Install Kitty (pinned version 0.46.2)
#############################################

install_kitty() {
  local version="0.46.2"

  info "==> Installing Kitty v$version"

  curl -L "https://sw.kovidgoyal.net/kitty/installer.sh" | sh /dev/stdin \
    version="$version"

  mkdir -p "$HOME/.local/bin"

  ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
}

if ! command -v kitty >/dev/null 2>&1; then
  install_kitty
else
  echo "==> Kitty already installed"
fi

#############################################
# 7. Symlink Kitty config
#############################################

mkdir -p "$HOME/.config/kitty"

read -p "Symlink kitty.conf from repo? [y/N] " symlink_kitty

if [[ "$symlink_kitty" =~ ^[Yy]$ ]]; then
  ln -sf "$REPO_ROOT/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
  echo "==> kitty.conf symlinked"
fi

#############################################
# 8. Done
#############################################

echo "==> Zsh + Kitty setup complete"
echo "Restart your terminal to apply changes"
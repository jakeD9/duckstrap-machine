#!/usr/bin/env bash

# ----------------------------
# Colors
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ----------------------------
# OS/Package Manager detection
# ----------------------------
OS="$(uname -s)"

detect_pm() {
  if [[ "$OS" == "Darwin" ]]; then
    echo "brew"
  elif [[ "$OS" == "Linux" ]]; then
    # basic assumption (you can refine later)
    if command -v apt >/dev/null 2>&1; then
      echo "apt"
    elif command -v pacman >/dev/null 2>&1; then
      echo "pacman"
    else
      echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

# ----------------------------
# OS aware package installs
# ----------------------------
PM="$(detect_pm)"

install() {
  local package="$1"

  case "$PM" in
    brew)
      info "Installing $package via brew"
      brew install "$package"
      ;;
    apt)
      info "Installing $package via apt"
      sudo apt update -y >/dev/null 2>&1
      sudo apt install -y "$package"
      ;;
    pacman)
      info "Installing $package via pacman"
      sudo pacman -S --noconfirm "$package"
      ;;
    *)
      error "No supported package manager found"
      return 1
      ;;
  esac
}

# ----------------------------
# Symlink file util
# ----------------------------
link_file() {
  local src="$1"
  local dest="$2"

  # If destination doesn't exist → just link
  if [[ ! -e "$dest" ]]; then
    ln -s "$src" "$dest"
    success "Linked $dest → $src"
    return
  fi

  # If already the correct symlink → do nothing
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    success "$dest already linked"
    return
  fi

  warn "$dest already exists"

  echo "What would you like to do?"
  echo "[o] Overwrite"
  echo "[b] Backup and replace"
  echo "[s] Skip"
  read -rp "> " choice

  case "$choice" in
    o|O)
      rm -rf "$dest"
      ln -s "$src" "$dest"
      success "Overwritten $dest"
      ;;
    b|B)
      mv "$dest" "${dest}.backup.$(date +%s)"
      ln -s "$src" "$dest"
      success "Backed up and linked $dest"
      ;;
    *)
      warn "Skipped $dest"
      ;;
  esac
}

# ----------------------------
# Logging helpers
# ----------------------------
info() {
  echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}
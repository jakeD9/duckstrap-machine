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

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_linux() {
  if [[ "$OS" != "Linux" ]]; then
    error "This script currently supports Linux only"
    return 1
  fi
}

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

install_if_missing() {
  local command_name="$1"
  local package_name="${2:-$1}"

  if command_exists "$command_name"; then
    success "$command_name already installed"
    return 0
  fi

  install "$package_name"
}

install_packages() {
  local package

  for package in "$@"; do
    install "$package"
  done
}

prompt_yes_no() {
  local prompt="$1"
  local default_answer="${2:-N}"
  local reply

  read -rp "$prompt [$default_answer] " reply
  reply="${reply:-$default_answer}"

  [[ "$reply" =~ ^[Yy]$ ]]
}

# ----------------------------
# Copy file util
# ----------------------------
copy_file() {
  local src="$1"
  local dest="$2"

  # If destination doesn't exist, just copy it into place.
  if [[ ! -e "$dest" ]]; then
    cp "$src" "$dest"
    success "Copied $src to $dest"
    return
  fi

  # If the destination already matches the source, do nothing.
  if cmp -s "$src" "$dest"; then
    success "$dest already matches the repo copy"
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
      cp "$src" "$dest"
      success "Overwrote $dest"
      ;;
    b|B)
      mv "$dest" "${dest}.backup.$(date +%s)"
      cp "$src" "$dest"
      success "Backed up and copied $dest"
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

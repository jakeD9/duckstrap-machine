#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load shared utils
source "$REPO_ROOT/utils.sh"

info "🔧 Setting up Git configuration..."

# ----------------------------
# Identity
# ----------------------------
if ! git config --global user.name >/dev/null 2>&1; then
  read -p "Git user name: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi

if ! git config --global user.email >/dev/null 2>&1; then
  read -p "Git email (GitHub noreply recommended): " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

# ----------------------------
# Core 
# ----------------------------
git config --global init.defaultBranch main
git config --global core.editor "code --wait"

# ----------------------------
# Aliases
# ----------------------------
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.lg "log --oneline --graph --decorate --all"



success "✅ Git setup complete"

# ----------------------------
# SSH setup
# ----------------------------
info "..."
info "🔐 Checking SSH setup..."

SSH_KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY" ]; then
  if prompt_yes_no "No SSH key found. Generate one now?" "N"; then
    read -p "Username for SSH key: " SSH_EMAIL

    ssh-keygen -t ed25519 -C "$SSH_EMAIL"

    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"
  else
    warn "⚠️ Skipping SSH key generation"
  fi
else
  success "✅ SSH key already exists"
fi

# ----------------------------
# Show public key
# ----------------------------
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo ""
  info "📋 Your public SSH key (copy this into GitHub): \n"
  echo "------------------------------------------------"
  cat "$HOME/.ssh/id_ed25519.pub"
  echo "------------------------------------------------"
fi


# ----------------------------
# Test SSH connection
# ----------------------------
if prompt_yes_no "Test SSH connection to GitHub now?" "N"; then
  info "Testing SSH connection... \n"
  ssh -T git@github.com || true
  echo ""
  info "If successful, you should see: 'You've successfully authenticated'"
fi

success "🎉 Git + SSH setup complete"

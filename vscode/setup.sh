#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load shared utils
source "$REPO_ROOT/utils.sh"

EXT_FILE="$(dirname "$0")/extensions.txt"

info "Setting up VS Code..."

# ----------------------------
# Detect Install Source
# ----------------------------
install_vscode() {
  local pm
  pm="$(detect_pm)"

  if command -v code >/dev/null 2>&1; then
    success "VS Code already installed"
    return
  fi

  case "$pm" in
    brew)
      info "Installing VS Code via Homebrew..."
      brew install --cask visual-studio-code
      ;;

    apt)
      info "Installing VS Code via apt (adding Microsoft repo)..."

      # Add Microsoft GPG key + repo if not already present
      if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        info "Adding Microsoft VS Code repository..."

        wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
          | gpg --dearmor \
          | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null

        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
          | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

        sudo apt update
      else
        info "VS Code repository already configured"
      fi

      install code
      ;;

    *)
      error "Unsupported package manager for VS Code: $pm"
      return 1
      ;;
  esac

  # Verify install
  if command -v code >/dev/null 2>&1; then
    success "VS Code installed successfully"
  else
    warn "VS Code installation completed but 'code' CLI not found"
    warn "You may need to enable it manually in VS Code"
  fi
}

# ----------------------------
# Install VS Code
# ----------------------------
install_vscode

# ----------------------------
# Verify CLI
# ----------------------------
if ! command -v code >/dev/null; then
  error "'code' CLI not found. Enable it in VS Code: Command Palette → 'Shell Command: Install code command'"
  exit 1
fi

success "VS Code CLI available"

# ----------------------------
# Install extensions
# ----------------------------
if [[ ! -f "$EXT_FILE" ]]; then
  error "extensions.txt not found at $EXT_FILE"
  exit 1
fi

info "Installing VS Code extensions..."

while read -r ext; do
  [[ -z "$ext" || "$ext" == \#* ]] && continue

  info "Installing: $ext"
  code --install-extension "$ext"
done < "$EXT_FILE"

success "VS Code setup complete"
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_if_exists() {
  local source_path="$1"
  local destination_path="$2"
  local label="$3"

  if [ ! -f "$source_path" ]; then
    echo "Skipping $label: not found at $source_path"
    return 0
  fi

  mkdir -p "$(dirname "$destination_path")"
  cp "$source_path" "$destination_path"
  echo "Copied $label"
}

import_files() {
  copy_if_exists "$HOME/.zshrc" "$SCRIPT_DIR/zsh/.zshrc" ".zshrc into repo"
  copy_if_exists "$HOME/.p10k.zsh" "$SCRIPT_DIR/p10k/.p10k.zsh" ".p10k.zsh into repo"
  copy_if_exists "$HOME/.config/kitty/kitty.conf" "$SCRIPT_DIR/kitty/kitty.conf" "kitty.conf into repo"
}

export_files() {
  copy_if_exists "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc" ".zshrc to machine"
  copy_if_exists "$SCRIPT_DIR/p10k/.p10k.zsh" "$HOME/.p10k.zsh" ".p10k.zsh to machine"
  copy_if_exists "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf" "kitty.conf to machine"
}

case "${1:-}" in
  --import)
    import_files
    ;;
  --export)
    export_files
    ;;
  *)
    echo "Specify --import or --export."
    exit 1
    ;;
esac

echo "To reload configs: run 'source ~/.zshrc' for your current shell and/or 'kitty @ load-config ~/.config/kitty/kitty.conf' for Kitty."

#!/usr/bin/env bash
set -euo pipefail

theme_id="Catppuccin.catppuccin-vsc"
icons_id="Catppuccin.catppuccin-vsc-icons"

install_for() {
  local editor="$1"
  if ! command -v "$editor" >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing Catppuccin for $editor..."
  "$editor" --install-extension "$theme_id" >/dev/null 2>&1 || true
  "$editor" --install-extension "$icons_id" >/dev/null 2>&1 || true
}

echo "==> VS Code / VSCodium Catppuccin setup"
install_for code
install_for codium
install_for code-insiders

echo "Done. Re-run changeTheme to apply the current Catppuccin flavour to the editor settings."

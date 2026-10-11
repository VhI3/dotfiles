#!/usr/bin/env bash
set -euo pipefail

yes=0

usage() {
  cat <<'EOF'
Usage: update-nvim [--yes]

Install or update the official Neovim AppImage in:
  ~/.opt/nvim/nvim.appimage

Options:
  --yes    Do not ask before installing/updating.
  -h       Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes|-y)
      yes=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "update-nvim: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

log() {
  printf '%s\n' "$*"
}

normalize_version() {
  local version="$1"
  version="${version#v}"
  printf '%s\n' "$version"
}

get_installed_version() {
  local output first_line version

  if ! command -v nvim >/dev/null 2>&1; then
    printf 'none\n'
    return 0
  fi

  if ! output="$(nvim --version 2>/dev/null)"; then
    printf 'none\n'
    return 0
  fi

  first_line="$(printf '%s\n' "$output" | sed -n '1p')"
  version="$(printf '%s\n' "$first_line" | sed -E 's/^NVIM v?([0-9][^[:space:]]*).*/\1/')"

  if [ -z "$version" ] || [ "$version" = "$first_line" ]; then
    printf 'none\n'
  else
    normalize_version "$version"
  fi
}

fetch_latest_tag() {
  curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest |
    sed -nE 's/.*"tag_name": "([^"]+)".*/\1/p' |
    head -n 1
}

should_install() {
  local installed="$1"
  local latest="$2"

  [ "$installed" = "none" ] && return 0
  dpkg --compare-versions "$installed" lt "$latest"
}

confirm_install() {
  local installed="$1"
  local latest_tag="$2"

  if [ "$yes" -eq 1 ]; then
    return 0
  fi

  if [ "$installed" = "none" ]; then
    read -r -p "Install Neovim $latest_tag AppImage? [y/N] " response
  else
    read -r -p "Update Neovim $installed -> $latest_tag? [y/N] " response
  fi

  [[ "$response" = [yY] || "$response" = [yY][eE][sS] ]]
}

install_appimage() {
  local latest_tag="$1"
  local tmp_file

  tmp_file="$(mktemp /tmp/nvim-appimage.XXXXXX)"
  trap 'rm -f "$tmp_file"' RETURN

  mkdir -p "$HOME/.opt/nvim" "$HOME/.local/bin"
  curl -fL \
    "https://github.com/neovim/neovim/releases/download/${latest_tag}/nvim-linux-x86_64.appimage" \
    -o "$tmp_file"
  chmod u+x "$tmp_file"
  mv "$tmp_file" "$HOME/.opt/nvim/nvim.appimage"
  ln -sf "$HOME/.opt/nvim/nvim.appimage" "$HOME/.local/bin/nvim"
  trap - RETURN
}

echo "--------🅥 🅗 🅘 ➌------ᴺᵉᵒⱽⁱᵐ------ {"

installed_version="$(get_installed_version)"

if ! latest_tag="$(fetch_latest_tag)"; then
  log "Could not check latest Neovim release from GitHub. Skipping AppImage update."
  echo "--------🅥 🅗 🅘 ➌------ᴺᵉᵒⱽⁱᵐ------ }"
  exit 0
fi

latest_version="$(normalize_version "$latest_tag")"

if should_install "$installed_version" "$latest_version"; then
  log "Neovim installed version: $installed_version"
  log "Neovim latest version:    $latest_version"
  if confirm_install "$installed_version" "$latest_tag"; then
    log "Downloading Neovim $latest_tag AppImage..."
    install_appimage "$latest_tag"
    log "Neovim $latest_version installed successfully."
  else
    log "Neovim update skipped."
  fi
else
  log "Neovim is up-to-date (version $installed_version)."
fi

echo "--------🅥 🅗 🅘 ➌------ᴺᵉᵒⱽⁱᵐ------ }"

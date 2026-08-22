#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: remove-software <package-name> [match-pattern ...]" >&2
  echo "Example: remove-software brave-browser brave" >&2
  exit 1
fi

if command -v nala >/dev/null 2>&1; then
  PKG_MGR="nala"
else
  PKG_MGR="apt"
fi

PACKAGE="$1"
shift

declare -a PATTERNS
PATTERNS=("$PACKAGE")
if [ "$#" -gt 0 ]; then
  PATTERNS+=("$@")
fi

contains_pattern() {
  local haystack="$1"
  local needle
  shopt -s nocasematch
  for needle in "${PATTERNS[@]}"; do
    if [[ "$haystack" == *"$needle"* ]]; then
      shopt -u nocasematch
      return 0
    fi
  done
  shopt -u nocasematch
  return 1
}

find_source_candidates() {
  local path content
  for path in /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [ -e "$path" ] || continue
    if contains_pattern "$(basename "$path")"; then
      printf '%s\n' "$path"
      continue
    fi
    content="$(sudo cat "$path" 2>/dev/null || true)"
    if contains_pattern "$content"; then
      printf '%s\n' "$path"
    fi
  done
}

find_keyring_candidates() {
  local path
  for path in /usr/share/keyrings/* /etc/apt/keyrings/*; do
    [ -e "$path" ] || continue
    if contains_pattern "$(basename "$path")"; then
      printf '%s\n' "$path"
    fi
  done
}

echo "==> Removing package: $PACKAGE"
sudo "$PKG_MGR" purge -y "$PACKAGE" || true
sudo "$PKG_MGR" autoremove -y || true

mapfile -t SOURCE_FILES < <(find_source_candidates | sort -u)
mapfile -t KEYRING_FILES < <(find_keyring_candidates | sort -u)

if [ "${#SOURCE_FILES[@]}" -gt 0 ]; then
  echo "==> Removing matching apt source files"
  printf '  %s\n' "${SOURCE_FILES[@]}"
  sudo rm -f "${SOURCE_FILES[@]}"
fi

if [ "${#KEYRING_FILES[@]}" -gt 0 ]; then
  echo "==> Removing matching keyrings"
  printf '  %s\n' "${KEYRING_FILES[@]}"
  sudo rm -f "${KEYRING_FILES[@]}"
fi

echo "==> Refreshing package lists"
sudo "$PKG_MGR" update

echo "==> Done"

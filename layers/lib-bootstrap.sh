#!/bin/bash
set -euo pipefail

ensure_root_tools() {
    local missing=0

    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        return 0
    fi

    for cmd in curl wget git gpg lsb_release unzip xz; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing=1
            break
        fi
    done

    if [ "$missing" -eq 1 ]; then
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            ca-certificates curl wget git gnupg lsb-release unzip xz-utils
    fi
}

ensure_user_bootstrap_tools() {
    local missing=0

    for cmd in curl wget git gpg lsb_release unzip xz; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing=1
            break
        fi
    done

    if [ "$missing" -eq 1 ]; then
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
            ca-certificates curl wget git gnupg lsb-release unzip xz-utils
    fi
}

ensure_local_bin() {
    mkdir -p "$HOME/.local/bin"
}

ensure_apt_keyring_dir() {
    sudo mkdir -p /etc/apt/keyrings /usr/share/keyrings
}

repo_file_contains_line() {
    local file="$1"
    local line="$2"
    [ -f "$file" ] && grep -Fxq "$line" "$file"
}

write_repo_line() {
    local file="$1"
    local line="$2"

    if ! repo_file_contains_line "$file" "$line"; then
        printf '%s\n' "$line" | sudo tee "$file" >/dev/null
    fi
}

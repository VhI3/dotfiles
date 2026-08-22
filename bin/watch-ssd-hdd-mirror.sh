#!/usr/bin/env bash
set -euo pipefail

document_env="${HOME}/.config/dotfiles/document-drives.env"

if [ -f "$document_env" ]; then
    # shellcheck disable=SC1090
    . "$document_env"
fi

src="${DOCUMENTS_SSD_MOUNT:-/media/$USER/Documents_1}"
dest="${DOCUMENTS_HDD_MOUNT:-/media/$USER/Documents_2}"

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "watch-ssd-hdd-mirror: required command missing: $1" >&2
        exit 1
    }
}

need_cmd inotifywait

if ! mountpoint -q "$src"; then
    echo "watch-ssd-hdd-mirror: source is not mounted: $src" >&2
    exit 1
fi

if ! mountpoint -q "$dest"; then
    echo "watch-ssd-hdd-mirror: destination is not mounted: $dest" >&2
    exit 1
fi

echo "watch-ssd-hdd-mirror: source=$src"
echo "watch-ssd-hdd-mirror: destination=$dest"
echo "watch-ssd-hdd-mirror: running initial mirror"
"$HOME/.local/bin/mirror-drive" --apply "$src" "$dest"

while true; do
    echo "watch-ssd-hdd-mirror: waiting for filesystem changes..."
    inotifywait \
        --recursive \
        --quiet \
        --event close_write,create,delete,move,attrib \
        --exclude '(^|/)(\\.mirror-history|lost\\+found)(/|$)' \
        "$src" >/dev/null

    # Batch bursts of filesystem changes into a single mirror run.
    sleep 3

    if ! mountpoint -q "$src" || ! mountpoint -q "$dest"; then
        echo "watch-ssd-hdd-mirror: one of the drives is no longer mounted" >&2
        exit 1
    fi

    echo "watch-ssd-hdd-mirror: change detected, mirroring..."
    "$HOME/.local/bin/mirror-drive" --apply "$src" "$dest"
done

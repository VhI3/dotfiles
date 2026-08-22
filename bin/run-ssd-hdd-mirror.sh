#!/usr/bin/env bash
set -euo pipefail

document_env="${HOME}/.config/dotfiles/document-drives.env"

if [ -f "$document_env" ]; then
    # shellcheck disable=SC1090
    . "$document_env"
fi

src="${DOCUMENTS_SSD_MOUNT:-/media/$USER/Documents_1}"
dest="${DOCUMENTS_HDD_MOUNT:-/media/$USER/Documents_2}"

if ! mountpoint -q "$src"; then
    echo "run-ssd-hdd-mirror: source is not mounted: $src" >&2
    exit 1
fi

if ! mountpoint -q "$dest"; then
    echo "run-ssd-hdd-mirror: destination is not mounted: $dest" >&2
    exit 1
fi

exec "$HOME/.local/bin/mirror-drive" --apply "$src" "$dest"

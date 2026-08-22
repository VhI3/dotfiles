#!/usr/bin/env bash
set -euo pipefail

document_env="${HOME}/.config/dotfiles/document-drives.env"

if [ -f "$document_env" ]; then
    # shellcheck disable=SC1090
    . "$document_env"
fi

src="${DOCUMENTS_SSD_MOUNT:-/media/$USER/Documents_1}"
dest="${DOCUMENTS_HDD_MOUNT:-/media/$USER/Documents_2}"

if [ ! -f "$HOME/.config/restic-backup.conf" ]; then
    echo "enable-restic-documents-backup: missing ~/.config/restic-backup.conf" >&2
    echo "Create or review it first, then run this command again." >&2
    exit 1
fi

if ! mountpoint -q "$src" || ! mountpoint -q "$dest"; then
    echo "enable-restic-documents-backup: both document drives must be mounted first." >&2
    exit 1
fi

if ! "$HOME/.local/bin/restic-backup" snapshots >/dev/null 2>&1; then
    echo "Initializing restic repository first..."
    "$HOME/.local/bin/restic-backup" init
fi

systemctl --user daemon-reload
systemctl --user enable --now restic-documents-backup.timer
systemctl --user start restic-documents-backup.service
systemctl --user list-timers restic-documents-backup.timer --all

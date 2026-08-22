#!/usr/bin/env bash
set -euo pipefail

if ! command -v inotifywait >/dev/null 2>&1; then
    echo "enable-ssd-hdd-live-sync: inotifywait is missing." >&2
    echo "Install it with: sudo nala install inotify-tools" >&2
    exit 1
fi

systemctl --user daemon-reload
systemctl --user disable --now ssd-hdd-mirror.timer ssd-hdd-mirror-fast.timer >/dev/null 2>&1 || true
systemctl --user enable --now ssd-hdd-live-sync.service
systemctl --user status ssd-hdd-live-sync.service --no-pager -l

#!/usr/bin/env bash
set -euo pipefail

systemctl --user daemon-reload
systemctl --user disable --now paperless-export-backup.timer >/dev/null 2>&1 || true
systemctl --user enable --now paperless-export-backup-fast.timer
systemctl --user start paperless-export-backup.service
systemctl --user list-timers 'paperless-export-backup*.timer' --all


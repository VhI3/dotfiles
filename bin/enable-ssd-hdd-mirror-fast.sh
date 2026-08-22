#!/usr/bin/env bash
set -euo pipefail

systemctl --user daemon-reload
systemctl --user disable --now ssd-hdd-mirror.timer >/dev/null 2>&1 || true
systemctl --user enable --now ssd-hdd-mirror-fast.timer
systemctl --user start ssd-hdd-mirror.service
systemctl --user list-timers 'ssd-hdd-mirror*.timer' --all

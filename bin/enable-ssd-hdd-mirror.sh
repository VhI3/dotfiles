#!/usr/bin/env bash
set -euo pipefail

systemctl --user daemon-reload
systemctl --user enable --now ssd-hdd-mirror.timer
systemctl --user start ssd-hdd-mirror.service
systemctl --user list-timers ssd-hdd-mirror.timer --all

#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$(cd "$(dirname "$0")/.." && pwd)"
user_name="${SUDO_USER:-$USER}"
user_home="$(getent passwd "$user_name" | cut -d: -f6)"

if [ -z "$user_home" ] || [ ! -d "$user_home" ]; then
    echo "Could not determine home directory for user: $user_name" >&2
    exit 1
fi

service_path="/etc/systemd/system/mount-media-shares.service"
script_path="$user_home/.local/bin/mount-media-shares"
credentials_path="${SMB_CREDENTIALS_FILE:-$user_home/.smb/casaos}"
host_value="${SMB_HOST:-192.168.178.114}"
filme_mount="${FILME_MOUNT:-/mnt/filme}"
tv_mount="${TV_SHOWS_MOUNT:-/mnt/tv_show}"

if [ ! -x "$script_path" ]; then
    echo "Expected linked script not found: $script_path" >&2
    echo "Run ./dots/link.sh first." >&2
    exit 1
fi

sudo tee "$service_path" >/dev/null <<EOF
[Unit]
Description=Mount SMB media shares
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
Environment=SMB_HOST=$host_value
Environment=SMB_CREDENTIALS_FILE=$credentials_path
Environment=FILME_MOUNT=$filme_mount
Environment=TV_SHOWS_MOUNT=$tv_mount
ExecStart=$script_path

[Install]
WantedBy=multi-user.target
EOF

if systemctl list-unit-files | grep -q '^NetworkManager-wait-online.service'; then
    sudo systemctl enable NetworkManager-wait-online.service >/dev/null 2>&1 || true
fi

sudo systemctl daemon-reload
sudo systemctl enable --now mount-media-shares.service

echo "Installed and started: $service_path"
sudo systemctl --no-pager --full status mount-media-shares.service | sed -n '1,30p'

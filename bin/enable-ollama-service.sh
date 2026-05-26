#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/share/ollama/models"

systemctl --user daemon-reload
systemctl --user enable --now ollama

echo "==> Ollama user service enabled"
systemctl --user --no-pager --full status ollama | sed -n '1,20p'

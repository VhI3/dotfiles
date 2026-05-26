#!/usr/bin/env bash
set -euo pipefail

if command -v nala >/dev/null 2>&1; then
    PKG_MGR="nala"
else
    PKG_MGR="apt"
fi

echo "==> Stopping Ollama services and processes"
sudo systemctl stop ollama 2>/dev/null || true
sudo systemctl disable ollama 2>/dev/null || true
systemctl --user stop ollama 2>/dev/null || true
systemctl --user disable ollama 2>/dev/null || true
pkill ollama 2>/dev/null || true

echo "==> Removing Ollama package if installed"
sudo "$PKG_MGR" purge -y ollama 2>/dev/null || true

echo "==> Removing Ollama binaries"
sudo rm -f /usr/local/bin/ollama
sudo rm -f /usr/bin/ollama

echo "==> Removing Ollama service files"
sudo rm -f /etc/systemd/system/ollama.service
sudo rm -f /usr/lib/systemd/system/ollama.service
rm -f "$HOME/.config/systemd/user/ollama.service"
systemctl --user daemon-reload 2>/dev/null || true
sudo systemctl daemon-reload

echo "==> Removing Ollama data"
rm -rf "$HOME/.ollama"
sudo rm -rf /usr/share/ollama /var/lib/ollama /etc/ollama

echo "==> Cleaning package leftovers"
sudo "$PKG_MGR" autoremove -y || true

echo "==> Refreshing package lists"
sudo "$PKG_MGR" update || true

echo "==> Ollama removal complete"

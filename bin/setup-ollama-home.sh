#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-$HOME/.local/share/ollama/models}"
bashrc="$HOME/.bashrc"
profile="$HOME/.profile"

ensure_export() {
    local file="$1"
    local line="export OLLAMA_MODELS=\"$target_dir\""

    touch "$file"

    if grep -q '^export OLLAMA_MODELS=' "$file"; then
        perl -0pi -e 's@^export OLLAMA_MODELS=.*$@'"$line"'@m' "$file"
    else
        printf '\n%s\n' "$line" >> "$file"
    fi
}

echo "==> Creating Ollama model directory"
mkdir -p "$target_dir"

echo "==> Configuring shell environment"
ensure_export "$bashrc"
ensure_export "$profile"
export OLLAMA_MODELS="$target_dir"

echo "==> OLLAMA_MODELS set to"
echo "    $OLLAMA_MODELS"
echo
echo "Next steps:"
echo "    source ~/.bashrc"
echo "    ollama pull gemma4:e4b"
echo "    ollama run gemma4:e4b"

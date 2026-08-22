#!/usr/bin/env bash
set -euo pipefail

if command -v ollama >/dev/null 2>&1; then
    exec "$(command -v ollama)" serve
fi

for candidate in /usr/local/bin/ollama "$HOME/.local/bin/ollama"; do
    if [ -x "$candidate" ]; then
        exec "$candidate" serve
    fi
done

echo "ollama-serve: ollama binary not found" >&2
exit 1

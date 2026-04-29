#!/usr/bin/env bash
set -euo pipefail

MODEL="${LLAMA_VSCODE_MODEL:-ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF}"
PORT="${LLAMA_VSCODE_PORT:-8012}"
HOST="${LLAMA_VSCODE_HOST:-127.0.0.1}"

if ! command -v llama-server >/dev/null 2>&1; then
  echo "llama-server was not found on PATH." >&2
  echo "Run setup-llama-vscode first, then open a new shell or source ~/.bashrc." >&2
  exit 1
fi

exec llama-server \
  --host "${HOST}" \
  --port "${PORT}" \
  -hf "${MODEL}" \
  -ub 1024 \
  -b 1024 \
  -dt 0.1 \
  --ctx-size 0 \
  --cache-reuse 256

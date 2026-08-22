#!/usr/bin/env bash
set -euo pipefail

LOCAL_BIN="${HOME}/.local/bin"
TARGET="${LOCAL_BIN}/llama-server"
PREFERRED_SOURCE="${HOME}/src/llama.cpp/build/bin/llama-server"

find_source() {
  local candidate

  if [ -n "${LLAMA_SERVER_SOURCE:-}" ] && [ -x "${LLAMA_SERVER_SOURCE}" ]; then
    printf '%s\n' "${LLAMA_SERVER_SOURCE}"
    return 0
  fi

  for candidate in \
    "${PREFERRED_SOURCE}" \
    "${HOME}/.unsloth/llama.cpp/build/bin/llama-server"; do
    if [ -x "${candidate}" ]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

SOURCE="$(find_source || true)"

if [ -z "${SOURCE}" ]; then
  echo "Could not find an executable llama-server binary." >&2
  echo "Checked:" >&2
  echo "  ${PREFERRED_SOURCE}" >&2
  echo "  ${HOME}/.unsloth/llama.cpp/build/bin/llama-server" >&2
  echo "Set LLAMA_SERVER_SOURCE=/path/to/llama-server and run again if yours lives somewhere else." >&2
  exit 1
fi

mkdir -p "${LOCAL_BIN}"
ln -sfn "${SOURCE}" "${TARGET}"

echo "==> llama.vscode local completion setup"
echo "Source: ${SOURCE}"
echo "Link:   ${TARGET}"
echo ""
ls -lh "${SOURCE}"
echo ""
"${SOURCE}" --version
echo ""

if command -v llama-server >/dev/null 2>&1; then
  echo "Current shell sees llama-server at:"
  command -v llama-server
else
  echo "Current shell does not yet see llama-server on PATH."
  echo "Open a new shell, run 'source ~/.bashrc', or start VS Code from a terminal with 'code'."
fi

echo ""
echo "Suggested next steps:"
echo "  1. which llama-server"
echo "  2. llama-vscode-cpu"
echo "  3. In another terminal: curl http://127.0.0.1:8012/health"

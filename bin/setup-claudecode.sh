#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAZYVIM_JSON="$DOTFILES_DIR/config/nvim/lazyvim.json"
LAZY_LOCK="$DOTFILES_DIR/config/nvim/lazy-lock.json"
PLUGIN_FILE="$DOTFILES_DIR/config/nvim/lua/plugins/claudecode.lua"
HELPER_FILE="$DOTFILES_DIR/config/nvim/lua/config/claude_helpers.lua"
OLD_CODEIUM_FILE="$DOTFILES_DIR/config/nvim/lua/plugins/codeium.lua"

detect_claude_cmd() {
  if command -v claude >/dev/null 2>&1; then
    command -v claude
    return 0
  fi

  if [ -x "$HOME/.claude/local/claude" ]; then
    printf '%s\n' "$HOME/.claude/local/claude"
    return 0
  fi

  return 1
}

echo "==> Claude Code Neovim setup"

if [ ! -f "$PLUGIN_FILE" ] || [ ! -f "$HELPER_FILE" ]; then
  echo "Claude Code dotfile config is missing." >&2
  echo "Expected:" >&2
  echo "  $PLUGIN_FILE" >&2
  echo "  $HELPER_FILE" >&2
  exit 1
fi

python3 - "$LAZYVIM_JSON" "$LAZY_LOCK" <<'PY'
import json
import pathlib
import sys

lazyvim_path = pathlib.Path(sys.argv[1])
lock_path = pathlib.Path(sys.argv[2])

lazyvim = json.loads(lazyvim_path.read_text(encoding="utf-8"))
extras = lazyvim.get("extras", [])
lazyvim["extras"] = [item for item in extras if item != "lazyvim.plugins.extras.ai.codeium"]
lazyvim_path.write_text(json.dumps(lazyvim, indent=2) + "\n", encoding="utf-8")

if lock_path.exists():
    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    changed = False
    for key in ("codeium.nvim", "codeium.vim"):
        if key in lock:
            del lock[key]
            changed = True
    if changed:
        lock_path.write_text(json.dumps(lock, indent=2) + "\n", encoding="utf-8")
PY

if [ -e "$OLD_CODEIUM_FILE" ]; then
  rm -f "$OLD_CODEIUM_FILE"
  echo "Removed stale Codeium plugin file."
fi

if claude_cmd="$(detect_claude_cmd)"; then
  echo "Detected Claude CLI: $claude_cmd"
else
  echo "Claude CLI was not found in PATH or ~/.claude/local/claude"
  echo "Install it first, for example:"
  echo "  curl -fsSL https://claude.ai/install.sh | bash"
fi

echo
echo "Claude Code settings are now managed from:"
echo "  $PLUGIN_FILE"
echo "  $HELPER_FILE"
echo
echo "Next steps:"
echo "  1. ./dots/link.sh"
echo "  2. nvim +Lazy sync"

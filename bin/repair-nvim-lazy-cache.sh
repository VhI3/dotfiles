#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
exec "$SCRIPT_DIR/nvim-repair.sh" lazy-cache "$@"

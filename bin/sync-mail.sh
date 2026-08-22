#!/bin/bash
set -euo pipefail

mkdir -p "$HOME/Mail" "$HOME/.cache/neomutt/headers" "$HOME/.cache/neomutt/bodies" "$HOME/.cache/msmtp"
mbsync -c "$HOME/.config/isync/mbsyncrc" -a

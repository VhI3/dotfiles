#!/usr/bin/env bash
set -euo pipefail

if [ -x "$HOME/.opt/octave/bin/octave" ]; then
    exec "$HOME/.opt/octave/bin/octave" --gui "$@"
fi

exec octave --gui "$@"

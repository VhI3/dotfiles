#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$SCRIPT_DIR/paperless-tools.lib.sh"
paperless_load_config

echo "==> Paperless health check"
echo "Compose dir: $PAPERLESS_COMPOSE_DIR"
echo "URL:         $PAPERLESS_URL"
echo "Consume dir: $PAPERLESS_CONSUME_DIR"
echo "Export dir:  $PAPERLESS_EXPORT_DIR"
echo

if [ "$PAPERLESS_SERVER_ONLY" != "1" ] && [ ! -d "$PAPERLESS_COMPOSE_DIR" ]; then
    echo "Error: compose directory not found: $PAPERLESS_COMPOSE_DIR" >&2
    exit 1
fi

compose_file=""
if [ "$PAPERLESS_SERVER_ONLY" != "1" ]; then
    compose_file="$(paperless_compose_file || true)"
fi

if [ "$PAPERLESS_SERVER_ONLY" != "1" ] && [ -z "$compose_file" ]; then
    echo "Error: no compose file found in $PAPERLESS_COMPOSE_DIR" >&2
    exit 1
fi

if [ "$PAPERLESS_SERVER_ONLY" != "1" ] && ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed or not in PATH." >&2
    exit 1
fi

if [ ! -d "$PAPERLESS_CONSUME_DIR" ]; then
    echo "Warning: consume directory does not exist yet: $PAPERLESS_CONSUME_DIR" >&2
fi

if [ "$PAPERLESS_SERVER_ONLY" = "1" ]; then
    echo "==> compose check"
    echo "Server-only/client mode enabled; skipping local docker compose checks."
    echo
else
    echo "==> docker compose ps"
    (
        cd "$PAPERLESS_COMPOSE_DIR"
        docker compose ps
    )
    echo
fi
echo "==> HTTP check"
if command -v curl >/dev/null 2>&1 && curl -fsS --max-time 5 "$PAPERLESS_URL" >/dev/null; then
    echo "Paperless is reachable at $PAPERLESS_URL"
else
    echo "Paperless is not reachable at $PAPERLESS_URL" >&2
    echo
    echo "Helpful hints:"
    echo "- Start the stack:"
    echo "    cd \"$PAPERLESS_COMPOSE_DIR\" && docker compose up -d"
    echo "- Check container logs:"
    echo "    cd \"$PAPERLESS_COMPOSE_DIR\" && docker compose logs --tail=100 webserver"
    echo "- Confirm port 8000 is free and mapped correctly."
    exit 1
fi

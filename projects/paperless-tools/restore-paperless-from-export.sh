#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$SCRIPT_DIR/paperless-tools.lib.sh"
paperless_load_config

SCRIPT_NAME="$(basename "$0")"

apply=0
allow_existing_documents=0
cleanup_staging=0
data_only=0
no_progress_bar=1
source_dir="${PAPERLESS_RESTORE_SOURCE:-}"
passphrase="${PAPERLESS_RESTORE_PASSPHRASE:-}"

usage() {
    cat <<'EOF'
Usage: restore-paperless-from-export.sh [options]

Safely restore a Paperless-ngx export into the configured Docker Compose stack.

Default mode is a dry run. Nothing is imported unless --apply is given.

Options:
  --source DIR                 Export directory containing manifest.json
  --apply                      Actually run document_importer
  --allow-existing-documents   Allow import when Paperless already has documents
  --cleanup-staging            Remove the temporary import staging folder after success
  --data-only                  Pass --data-only to document_importer
  --passphrase VALUE           Passphrase for encrypted exports
  --progress                   Show Paperless import progress bar
  -h, --help                   Show this help

Default source selection:
  1. PAPERLESS_RESTORE_SOURCE, if set
  2. SSD_BACKUP_TARGET, if it contains manifest.json
  3. PCLOUD_BACKUP_TARGET, if it contains manifest.json
  4. PAPERLESS_EXPORT_DIR, if it contains manifest.json

Safe restore pattern:
  restore-paperless-from-export.sh
  restore-paperless-from-export.sh --apply
EOF
}

log() {
    printf '%s: %s\n' "$SCRIPT_NAME" "$*"
}

die() {
    printf '%s: ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2
    exit 1
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --source)
            [ "$#" -ge 2 ] || die "--source needs a directory"
            source_dir="$2"
            shift
            ;;
        --apply)
            apply=1
            ;;
        --allow-existing-documents)
            allow_existing_documents=1
            ;;
        --cleanup-staging)
            cleanup_staging=1
            ;;
        --data-only)
            data_only=1
            ;;
        --passphrase)
            [ "$#" -ge 2 ] || die "--passphrase needs a value"
            passphrase="$2"
            shift
            ;;
        --progress)
            no_progress_bar=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown option: $1"
            ;;
    esac
    shift
done

choose_source_dir() {
    local candidate

    for candidate in \
        "$source_dir" \
        "$SSD_BACKUP_TARGET" \
        "$PCLOUD_BACKUP_TARGET" \
        "$PAPERLESS_EXPORT_DIR"
    do
        [ -n "$candidate" ] || continue
        if [ -f "$candidate/manifest.json" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

run_compose() {
    (
        cd "$PAPERLESS_COMPOSE_DIR"
        docker compose "$@"
    )
}

document_count() {
    run_compose exec -T webserver python manage.py shell -c \
        'from documents.models import Document; print(Document.objects.count())' \
        | sed -n '/^[0-9][0-9]*$/p' \
        | tail -n 1
}

safe_remove_staging() {
    local staging_dir="$1"
    local export_real
    local staging_real

    export_real="$(realpath -m "$PAPERLESS_EXPORT_DIR")"
    staging_real="$(realpath -m "$staging_dir")"

    case "$staging_real" in
        "$export_real"/restore-import-*)
            rm -rf "$staging_real"
            ;;
        *)
            die "refusing to clean unexpected staging path: $staging_real"
            ;;
    esac
}

require_command docker
require_command rsync

source_dir="$(choose_source_dir)" || die "no export source found. Pass --source DIR with a directory containing manifest.json"

[ -d "$source_dir" ] || die "export source is not a directory: $source_dir"
[ -f "$source_dir/manifest.json" ] || die "manifest.json not found in export source: $source_dir"

if command -v jq >/dev/null 2>&1; then
    jq empty "$source_dir/manifest.json" >/dev/null || die "manifest.json is not valid JSON: $source_dir/manifest.json"
fi

compose_file="$(paperless_compose_file || true)"
[ -n "$compose_file" ] || die "no compose file found in $PAPERLESS_COMPOSE_DIR"

if [ ! -d "$PAPERLESS_COMPOSE_DIR" ]; then
    die "Paperless compose directory not found: $PAPERLESS_COMPOSE_DIR"
fi

log "Paperless compose dir: $PAPERLESS_COMPOSE_DIR"
log "Export source:         $source_dir"
log "Compose export dir:    $PAPERLESS_EXPORT_DIR"
log "Container import root: $PAPERLESS_EXPORT_CONTAINER_DIR"

log "checking Paperless container"
if ! run_compose exec -T webserver document_importer --help >/dev/null 2>&1; then
    die "Paperless webserver is not reachable. Start it with: cd \"$PAPERLESS_COMPOSE_DIR\" && docker compose up -d"
fi

count="$(document_count)"
[ -n "$count" ] || die "could not determine current Paperless document count"
log "current Paperless document count: $count"

if [ "$count" -gt 0 ] && [ "$allow_existing_documents" -eq 0 ]; then
    if [ "$apply" -eq 1 ]; then
        die "Paperless already has $count documents. Refusing to import to avoid duplicates. Use --allow-existing-documents only if you understand the risk."
    fi
    log "dry-run warning: --apply would refuse because Paperless already has $count documents"
fi

if command -v jq >/dev/null 2>&1; then
    manifest_items="$(jq 'length' "$source_dir/manifest.json" 2>/dev/null || printf 'unknown')"
    log "manifest entries: $manifest_items"
fi

if [ "$apply" -eq 0 ]; then
    cat <<EOF

Dry run complete. Nothing was imported.

To restore into a fresh/empty Paperless instance, run:
  $SCRIPT_NAME --source "$source_dir" --apply

If you intentionally want to import into the current non-empty instance, run:
  $SCRIPT_NAME --source "$source_dir" --apply --allow-existing-documents

EOF
    exit 0
fi

mkdir -p "$PAPERLESS_EXPORT_DIR"

source_real="$(realpath "$source_dir")"
export_real="$(realpath -m "$PAPERLESS_EXPORT_DIR")"
staging_dir=""
container_source=""

if [ "$source_real" = "$export_real" ]; then
    log "source is already the compose export directory; importing directly"
    container_source="$PAPERLESS_EXPORT_CONTAINER_DIR"
else
    timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"
    staging_dir="$PAPERLESS_EXPORT_DIR/restore-import-$timestamp"
    container_source="$PAPERLESS_EXPORT_CONTAINER_DIR/restore-import-$timestamp"

    log "staging export for container import"
    log "staging dir: $staging_dir"
    mkdir -p "$staging_dir"
    rsync -a --info=progress2 "$source_real"/ "$staging_dir"/
fi

import_args=()
if [ "$no_progress_bar" -eq 1 ]; then
    import_args+=(--no-progress-bar)
fi
if [ "$data_only" -eq 1 ]; then
    import_args+=(--data-only)
fi
if [ -n "$passphrase" ]; then
    import_args+=(--passphrase "$passphrase")
fi
import_args+=("$container_source")

log "running Paperless document_importer"
run_compose exec -T webserver document_importer "${import_args[@]}"

log "import finished"
new_count="$(document_count)"
log "new Paperless document count: $new_count"

if [ -n "$staging_dir" ]; then
    if [ "$cleanup_staging" -eq 1 ]; then
        log "cleaning staging directory"
        safe_remove_staging "$staging_dir"
    else
        log "staging directory kept for inspection: $staging_dir"
    fi
fi

log "restore completed successfully"

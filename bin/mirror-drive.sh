#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: mirror-drive [--apply] [--no-history] SOURCE DEST

Mirror SOURCE into DEST with rsync.

Default mode is dry-run. Use --apply to perform changes.

Behavior:
  - makes DEST match SOURCE
  - removes files from DEST that no longer exist in SOURCE
  - by default, saves replaced/deleted files into DEST/.mirror-history/TIMESTAMP/
  - protects restic repositories under DEST from deletion during mirror runs

Options:
  --apply       Perform the mirror
  --no-history  Do not keep replaced/deleted files in .mirror-history
  -h, --help    Show this help

Examples:
  mirror-drive /media/$USER/ssd/ /media/$USER/hdd/
  mirror-drive --apply /media/$USER/ssd/ /media/$USER/hdd/
EOF
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "mirror-drive: required command missing: $1" >&2
        exit 1
    }
}

need_cmd rsync

apply=0
keep_history=1

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)
            apply=1
            ;;
        --no-history)
            keep_history=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "mirror-drive: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ "$#" -ne 2 ]; then
    usage >&2
    exit 1
fi

src="$1"
dest="$2"

if [ ! -d "$src" ]; then
    echo "mirror-drive: source directory not found: $src" >&2
    exit 1
fi

mkdir -p "$dest"

src_real="$(realpath "$src")"
dest_real="$(realpath "$dest")"

if [ "$src_real" = "$dest_real" ]; then
    echo "mirror-drive: source and destination are the same directory" >&2
    exit 1
fi

case "$dest_real" in
    "$src_real"/*)
        echo "mirror-drive: destination may not be inside source" >&2
        exit 1
        ;;
esac

stamp="$(date +%Y-%m-%d_%H-%M-%S)"
history_dir="$dest_real/.mirror-history/$stamp"

rsync_args=(
    -aHAXvh
    --delete-delay
    --partial
    --info=progress2
    --human-readable
)

if [ "$apply" -eq 0 ]; then
    rsync_args+=(-n)
fi

if [ "$keep_history" -eq 1 ]; then
    mkdir -p "$history_dir"
    rsync_args+=(
        --backup
        "--backup-dir=$history_dir"
        --exclude=.mirror-history/
    )
fi

rsync_args+=(
    --exclude=lost+found/
    --exclude=.restic*/
    --exclude=restic-laptop/
)

printf 'Source: %s\n' "$src_real"
printf 'Destination: %s\n' "$dest_real"

if [ "$apply" -eq 0 ]; then
    echo "Mode: dry-run"
else
    echo "Mode: apply"
fi

if [ "$keep_history" -eq 1 ]; then
    printf 'History: %s\n' "$history_dir"
else
    echo "History: disabled"
fi

rsync "${rsync_args[@]}" "$src_real"/ "$dest_real"/

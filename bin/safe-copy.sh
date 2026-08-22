#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: safe-copy [options] SOURCE... DEST

Safe, resumable rsync-based copy helper for local disks or remote paths.

Defaults:
  - recursive copy
  - preserve modification times
  - show overall progress
  - keep partial files so interrupted copies can resume
  - tolerate 1-second timestamp differences on removable filesystems

Options:
  -n, --dry-run          Preview without copying
  -V, --verify           Verify after copy with checksum comparison
      --ignore-existing  Skip files that already exist at destination
  -h, --help             Show this help

Examples:
  safe-copy /media/$USER/source-drive/ /media/$USER/backup-drive/
  safe-copy --dry-run ~/Downloads/ /mnt/backup/Downloads/
  safe-copy --verify movie.mkv user@server:/data/media/movies/

Notes:
  source/   copies the contents of the source directory
  source    copies the source directory itself
EOF
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "safe-copy: required command missing: $1" >&2
        exit 1
    }
}

need_cmd rsync

DRY_RUN=0
VERIFY=0
IGNORE_EXISTING=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            ;;
        -V|--verify)
            VERIFY=1
            ;;
        --ignore-existing)
            IGNORE_EXISTING=1
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
            echo "safe-copy: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ "$#" -lt 2 ]; then
    usage >&2
    exit 1
fi

dest="${!#}"
sources=("${@:1:$#-1}")

rsync_args=(
    -rtvh
    --info=progress2
    --partial
    --modify-window=1
)

if [ "$DRY_RUN" -eq 1 ]; then
    rsync_args+=(-n)
fi

if [ "$IGNORE_EXISTING" -eq 1 ]; then
    rsync_args+=(--ignore-existing)
fi

echo "Running: rsync ${rsync_args[*]} ${sources[*]} $dest"
rsync "${rsync_args[@]}" "${sources[@]}" "$dest"

if [ "$VERIFY" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
    echo
    echo "Verifying with checksum comparison..."

    verify_output="$(
        rsync -rthcni --modify-window=1 "${sources[@]}" "$dest"
    )"

    if [ -n "$verify_output" ]; then
        printf '%s\n' "$verify_output"
        echo "safe-copy: verification found differences." >&2
        exit 2
    fi

    echo "Verification passed."
fi

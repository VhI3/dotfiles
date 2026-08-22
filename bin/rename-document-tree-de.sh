#!/usr/bin/env bash
set -euo pipefail

apply=0
base_dir="$HOME/Documents"

usage() {
    cat <<'EOF'
Usage: rename-document-tree-de.sh [--apply] [directory]

Renames common English document-folder names to German equivalents.
Default mode is dry-run. Use --apply to perform the renames.

Examples:
  rename-document-tree-de.sh ~/Documents
  rename-document-tree-de.sh --apply /media/$USER/HDD/Documents
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)
            apply=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            base_dir="$1"
            ;;
    esac
    shift
done

if [ ! -d "$base_dir" ]; then
    echo "Directory not found: $base_dir" >&2
    exit 1
fi

declare -A RENAMES=(
    ["00-inbox"]="00-Eingang"
    ["10-records"]="10-Unterlagen"
    ["20-reference"]="20-Referenz"
    ["90-archive"]="90-Archiv"
    ["finance"]="Finanzen"
    ["contracts-insurance"]="Vertraege-und-Versicherungen"
    ["authorities"]="Behoerden"
    ["health"]="Gesundheit"
    ["certificates"]="Zertifikate"
)

rename_one() {
    local path="$1"
    local dir name target_name target

    dir="$(dirname "$path")"
    name="$(basename "$path")"
    target_name="${RENAMES[$name]:-}"

    if [ -z "$target_name" ] || [ "$target_name" = "$name" ]; then
        return 0
    fi

    target="$dir/$target_name"

    if [ -e "$target" ]; then
        printf 'skip (target exists): %s -> %s\n' "$path" "$target" >&2
        return 0
    fi

    if [ "$apply" -eq 1 ]; then
        mv -- "$path" "$target"
        printf 'renamed: %s -> %s\n' "$path" "$target"
    else
        printf 'would rename: %s -> %s\n' "$path" "$target"
    fi
}

find "$base_dir" -depth -type d | while IFS= read -r path; do
    rename_one "$path"
done

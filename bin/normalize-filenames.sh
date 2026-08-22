#!/usr/bin/env bash
set -euo pipefail

apply=0
target_dir="."
mode="all"

usage() {
    cat <<'EOF'
Usage: normalize-filenames.sh [--apply] [--folders-only|--files-only] [directory]

Normalizes file and directory names to a POSIX-friendly portable style:
- lowercase
- ASCII when possible
- no spaces
- hyphens instead of spaces
- only letters, numbers, dots, underscores, and hyphens
- no leading dash

Default mode is dry-run. Use --apply to actually rename entries.
EOF
}

sanitize_name() {
    local input="$1"
    local hidden=""
    local normalized=""

    if [[ "$input" == .* && "$input" != "." && "$input" != ".." ]]; then
        hidden="."
        input="${input#.}"
    fi

    if command -v iconv >/dev/null 2>&1; then
        normalized="$(printf '%s' "$input" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$input")"
    else
        normalized="$input"
    fi

    normalized="$(
        printf '%s' "$normalized" \
            | tr '[:upper:]' '[:lower:]' \
            | sed -E \
                -e 's/[[:space:]]+/-/g' \
                -e 's/[^a-z0-9._-]+/-/g' \
                -e 's/-+/-/g' \
                -e 's/^\.+//' \
                -e 's/^-+//' \
                -e 's/-+$//' \
                -e 's/\.-/./g'
    )"

    if [ -z "$normalized" ]; then
        normalized="unnamed"
    fi

    printf '%s%s\n' "$hidden" "$normalized"
}

add_suffix() {
    local name="$1"
    local suffix="$2"
    local hidden=""
    local base="$name"
    local ext=""

    if [[ "$name" == .* ]]; then
        hidden="."
        base="${name#.}"
    fi

    if [[ "$base" == *.* ]]; then
        ext=".${base##*.}"
        base="${base%.*}"
    fi

    printf '%s%s-%s%s\n' "$hidden" "$base" "$suffix" "$ext"
}

unique_name() {
    local dir="$1"
    local old_path="$2"
    local name="$3"
    local candidate="$name"
    local n=1

    while [ -e "$dir/$candidate" ] && [ "$dir/$candidate" != "$old_path" ]; do
        candidate="$(add_suffix "$name" "$n")"
        n=$((n + 1))
    done

    printf '%s\n' "$candidate"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)
            apply=1
            ;;
        --folders-only)
            mode="folders"
            ;;
        --files-only)
            mode="files"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            target_dir="$1"
            ;;
    esac
    shift
done

if [ ! -d "$target_dir" ]; then
    echo "Directory not found: $target_dir" >&2
    exit 1
fi

find "$target_dir" -depth -mindepth 1 | while IFS= read -r path; do
    if [ "$mode" = "folders" ] && [ ! -d "$path" ]; then
        continue
    fi

    if [ "$mode" = "files" ] && [ ! -f "$path" ]; then
        continue
    fi

    dir="$(dirname "$path")"
    name="$(basename "$path")"
    sanitized="$(sanitize_name "$name")"

    if [ "$sanitized" = "$name" ]; then
        continue
    fi

    target_name="$(unique_name "$dir" "$path" "$sanitized")"
    target_path="$dir/$target_name"

    if [ "$apply" -eq 1 ]; then
        mv -n -- "$path" "$target_path"
        printf 'renamed: %s -> %s\n' "$path" "$target_path"
    else
        printf 'would rename: %s -> %s\n' "$path" "$target_path"
    fi
done

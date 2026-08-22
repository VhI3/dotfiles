#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="."
APPLY=0
RECURSIVE=0
WITH_AUTHOR=0

usage() {
    cat <<'EOF'
Usage: rename-pdf-from-title [--apply] [--recursive] [--with-author] [--source DIR]

Rename PDF files using embedded PDF metadata, primarily the Title field.

Default behavior:
  - scan current directory
  - use Title metadata
  - optionally include Author with --with-author
  - normalize names into a POSIX-friendly style
  - dry run only

Examples:
  rename-pdf-from-title
  rename-pdf-from-title --source ~/Downloads/books-final/books
  rename-pdf-from-title --source ~/Downloads/books-final/books --with-author --apply
  rename-pdf-from-title --source ~/Downloads/books-final/papers --apply
EOF
}

sanitize_name() {
    local input="$1"
    local normalized=""

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
        normalized="untitled"
    fi

    printf '%s\n' "$normalized"
}

add_suffix() {
    local name="$1"
    local suffix="$2"
    local base="$name"
    local ext=""

    if [[ "$base" == *.* ]]; then
        ext=".${base##*.}"
        base="${base%.*}"
    fi

    printf '%s-%s%s\n' "$base" "$suffix" "$ext"
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

extract_field() {
    local key="$1"
    local info="$2"
    printf '%s\n' "$info" | awk -F: -v key="$key" '$1 == key {sub(/^[[:space:]]+/, "", $2); print $2; exit}'
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply)
            APPLY=1
            ;;
        --recursive)
            RECURSIVE=1
            ;;
        --with-author)
            WITH_AUTHOR=1
            ;;
        --source)
            shift
            SOURCE_DIR="${1:-}"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "rename-pdf-from-title: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

if ! command -v pdfinfo >/dev/null 2>&1; then
    echo "rename-pdf-from-title: pdfinfo is required (poppler-utils)." >&2
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "rename-pdf-from-title: source directory not found: $SOURCE_DIR" >&2
    exit 1
fi

find_args=("$SOURCE_DIR")
if [ "$RECURSIVE" -eq 0 ]; then
    find_args+=(-maxdepth 1)
fi
find_args+=(-type f -iname '*.pdf')

mapfile -t pdfs < <(find "${find_args[@]}" | sort)

if [ "${#pdfs[@]}" -eq 0 ]; then
    echo "rename-pdf-from-title: no PDF files found in $SOURCE_DIR"
    exit 0
fi

renames=0
for pdf in "${pdfs[@]}"; do
    dir="$(dirname "$pdf")"
    old_name="$(basename "$pdf")"
    info="$(pdfinfo "$pdf" 2>/dev/null || true)"
    title="$(extract_field "Title" "$info")"
    author="$(extract_field "Author" "$info")"

    if [ -z "$title" ]; then
        continue
    fi

    if [ "$WITH_AUTHOR" -eq 1 ] && [ -n "$author" ]; then
        new_base="$(sanitize_name "$author - $title")"
    else
        new_base="$(sanitize_name "$title")"
    fi

    target_name="$(unique_name "$dir" "$pdf" "$new_base.pdf")"
    target_path="$dir/$target_name"

    if [ "$target_name" = "$old_name" ]; then
        continue
    fi

    renames=$((renames + 1))
    if [ "$APPLY" -eq 1 ]; then
        mv -n -- "$pdf" "$target_path"
        printf 'renamed: %s -> %s\n' "$pdf" "$target_path"
    else
        printf 'would rename: %s -> %s\n' "$pdf" "$target_path"
    fi
done

if [ "$renames" -eq 0 ]; then
    echo "rename-pdf-from-title: no renames suggested."
    exit 0
fi

if [ "$APPLY" -eq 0 ]; then
    echo
    echo "Dry run only. Re-run with --apply to rename the files."
fi

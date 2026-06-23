#!/usr/bin/env bash
set -euo pipefail

if command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || true)"
fi
SCRIPT_PATH="${SCRIPT_PATH:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

SOURCE_DIR="${SORT_LIBRARY_SOURCE_DIR:-$HOME/Downloads/books-final}"
DEST_DIR="${SORT_LIBRARY_DEST_DIR:-$SOURCE_DIR}"
MIN_BOOK_PAGES="${SORT_LIBRARY_MIN_BOOK_PAGES:-80}"
MIN_PAPER_PAGES="${SORT_LIBRARY_MIN_PAPER_PAGES:-4}"
MAX_PAPER_PAGES="${SORT_LIBRARY_MAX_PAPER_PAGES:-60}"
TEXT_SAMPLE_PAGES="${SORT_LIBRARY_TEXT_SAMPLE_PAGES:-1}"
APPLY=0
COPY_ONLY=0
RECURSIVE=0

usage() {
    cat <<'EOF'
Usage: sort-library [--apply] [--copy] [--recursive] [--source DIR] [--dest DIR]
                    [--min-book-pages N] [--min-paper-pages N] [--max-paper-pages N]

Sort a mixed library folder.

Behavior:
  - exact-hash duplicates for non-PDF files go to duplicates/
  - PDFs are handed off to sort-pdfs and split into books/theses/papers/others/duplicates
  - non-PDF files are grouped into:
      archives/
      images/
      audio/
      videos/
      ebooks/
      documents/
      misc/

Default behavior:
  - scan ~/Downloads/books-final
  - sort in place under category subfolders
  - dry run only

Examples:
  sort-library
  sort-library --source ~/Downloads/books-final --dest ~/Downloads/books-final
  sort-library --source ~/Downloads/books-final --dest ~/Downloads/books-final --apply
  sort-library --source ~/Downloads/mixed --dest ~/Downloads/sorted --recursive --apply
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply)
            APPLY=1
            ;;
        --copy)
            COPY_ONLY=1
            ;;
        --recursive)
            RECURSIVE=1
            ;;
        --source)
            shift
            SOURCE_DIR="${1:-}"
            ;;
        --dest)
            shift
            DEST_DIR="${1:-}"
            ;;
        --min-book-pages)
            shift
            MIN_BOOK_PAGES="${1:-}"
            ;;
        --min-paper-pages)
            shift
            MIN_PAPER_PAGES="${1:-}"
            ;;
        --max-paper-pages)
            shift
            MAX_PAPER_PAGES="${1:-}"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "sort-library: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "sort-library: required command missing: $1" >&2
        exit 1
    }
}

need_cmd file
need_cmd sha256sum
need_cmd realpath

SORT_PDFS="$SCRIPT_DIR/sort-pdfs.sh"
if [ ! -x "$SORT_PDFS" ]; then
    SORT_PDFS="$(command -v sort-pdfs 2>/dev/null || true)"
fi
if [ -z "${SORT_PDFS:-}" ] || [ ! -x "$SORT_PDFS" ]; then
    echo "sort-library: sort-pdfs helper not found or not executable." >&2
    exit 1
fi

resolve_path() {
    realpath -m "$1"
}

lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

progress() {
    printf '[sort-library] %s\n' "$*" >&2
}

move_or_copy() {
    local src="$1"
    local target_dir="$2"
    local reason="$3"
    local target_path

    mkdir -p "$target_dir"
    target_path="$target_dir/$(basename "$src")"

    if [ -e "$target_path" ] && [ "$target_path" != "$src" ]; then
        local base ext n candidate
        ext=""
        base="$target_path"
        if [[ "$target_path" == *.* ]]; then
            ext=".${target_path##*.}"
            base="${target_path%.*}"
        fi
        n=1
        while :; do
            candidate="${base}-${n}${ext}"
            if [ ! -e "$candidate" ]; then
                target_path="$candidate"
                break
            fi
            n=$((n + 1))
        done
    fi

    if [ "$COPY_ONLY" -eq 1 ]; then
        cp "$src" "$target_path"
        printf '[copied] %s -> %s (%s)\n' "$src" "$target_path" "$reason"
    else
        mv "$src" "$target_path"
        printf '[moved] %s -> %s (%s)\n' "$src" "$target_path" "$reason"
    fi
}

classify_non_pdf() {
    local file="$1"
    local ext mime ext_lc

    mime="$(file --dereference --brief --mime-type -- "$file")"
    ext="${file##*.}"
    ext_lc="$(lower "$ext")"

    case "$mime" in
        image/*)
            printf 'images|mime=%s\n' "$mime"
            return 0
            ;;
        audio/*)
            printf 'audio|mime=%s\n' "$mime"
            return 0
            ;;
        video/*)
            printf 'videos|mime=%s\n' "$mime"
            return 0
            ;;
        application/epub+zip|application/x-mobipocket-ebook|application/x-fictionbook+xml)
            printf 'ebooks|mime=%s\n' "$mime"
            return 0
            ;;
        application/zip|application/x-7z-compressed|application/x-rar|application/vnd.rar|application/x-tar|application/gzip|application/x-gzip|application/x-bzip2|application/x-xz|application/zstd)
            printf 'archives|mime=%s\n' "$mime"
            return 0
            ;;
        text/*|application/msword|application/rtf|application/vnd.oasis.opendocument.text|application/vnd.oasis.opendocument.spreadsheet|application/vnd.oasis.opendocument.presentation|application/vnd.openxmlformats-officedocument.wordprocessingml.document|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|application/vnd.openxmlformats-officedocument.presentationml.presentation)
            printf 'documents|mime=%s\n' "$mime"
            return 0
            ;;
    esac

    case "$ext_lc" in
        zip|7z|rar|tar|gz|tgz|xz|bz2|zst|cbz|cbr)
            printf 'archives|ext=%s\n' "$ext_lc"
            ;;
        jpg|jpeg|png|gif|webp|bmp|tiff|svg|heic|avif)
            printf 'images|ext=%s\n' "$ext_lc"
            ;;
        mp3|m4a|flac|wav|ogg|opus|aac)
            printf 'audio|ext=%s\n' "$ext_lc"
            ;;
        mp4|mkv|avi|mov|webm)
            printf 'videos|ext=%s\n' "$ext_lc"
            ;;
        epub|mobi|azw3|fb2)
            printf 'ebooks|ext=%s\n' "$ext_lc"
            ;;
        doc|docx|odt|ods|odp|ppt|pptx|xls|xlsx|txt|md|org|rtf)
            printf 'documents|ext=%s\n' "$ext_lc"
            ;;
        *)
            printf 'misc|mime=%s\n' "$mime"
            ;;
    esac
}

SOURCE_DIR="$(resolve_path "$SOURCE_DIR")"
DEST_DIR="$(resolve_path "$DEST_DIR")"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "sort-library: source directory not found: $SOURCE_DIR" >&2
    exit 1
fi

ARCHIVES_DIR="$DEST_DIR/archives"
IMAGES_DIR="$DEST_DIR/images"
AUDIO_DIR="$DEST_DIR/audio"
VIDEOS_DIR="$DEST_DIR/videos"
EBOOKS_DIR="$DEST_DIR/ebooks"
DOCUMENTS_DIR="$DEST_DIR/documents"
MISC_DIR="$DEST_DIR/misc"
DUPLICATES_DIR="$DEST_DIR/duplicates"

declare -A NONPDF_HASH_SEEN=()

find_args=("$SOURCE_DIR")
if [ "$RECURSIVE" -eq 0 ]; then
    find_args+=(-maxdepth 1)
fi
find_args+=(-type f ! -iname '*.pdf')

if [[ "$DEST_DIR" == "$SOURCE_DIR" || "$DEST_DIR" == "$SOURCE_DIR/"* ]]; then
    find_args+=(
        ! -path "$ARCHIVES_DIR/*"
        ! -path "$IMAGES_DIR/*"
        ! -path "$AUDIO_DIR/*"
        ! -path "$VIDEOS_DIR/*"
        ! -path "$EBOOKS_DIR/*"
        ! -path "$DOCUMENTS_DIR/*"
        ! -path "$MISC_DIR/*"
        ! -path "$DUPLICATES_DIR/*"
        ! -path "$DEST_DIR/books/*"
        ! -path "$DEST_DIR/theses/*"
        ! -path "$DEST_DIR/papers/*"
        ! -path "$DEST_DIR/others/*"
    )
fi

mapfile -t non_pdfs < <(find "${find_args[@]}" | sort)

progress "found ${#non_pdfs[@]} non-PDF files in $SOURCE_DIR"

archives=0
images=0
audio=0
videos=0
ebooks=0
documents=0
misc=0
duplicates=0

if [ "${#non_pdfs[@]}" -gt 0 ]; then
    progress "phase 1/2: sorting non-PDF files"
fi

file_index=0
for path in "${non_pdfs[@]}"; do
    file_index=$((file_index + 1))
    if [ "$file_index" -eq 1 ] || [ $((file_index % 25)) -eq 0 ] || [ "$file_index" -eq "${#non_pdfs[@]}" ]; then
        progress "non-PDF $file_index/${#non_pdfs[@]}: $(basename "$path")"
    fi

    hash="$(sha256sum "$path" | awk '{print $1}')"
    if [ -n "${NONPDF_HASH_SEEN[$hash]:-}" ]; then
        duplicates=$((duplicates + 1))
        reason="duplicate-hash=$(basename "${NONPDF_HASH_SEEN[$hash]}")"
        if [ "$APPLY" -eq 0 ]; then
            printf '[duplicate] %s -> %s (%s)\n' "$path" "$DUPLICATES_DIR" "$reason"
        else
            move_or_copy "$path" "$DUPLICATES_DIR" "$reason"
        fi
        continue
    fi
    NONPDF_HASH_SEEN[$hash]="$path"

    classification="$(classify_non_pdf "$path")"
    category="${classification%%|*}"
    reason="${classification#*|}"

    case "$category" in
        archives)
            target_dir="$ARCHIVES_DIR"
            archives=$((archives + 1))
            ;;
        images)
            target_dir="$IMAGES_DIR"
            images=$((images + 1))
            ;;
        audio)
            target_dir="$AUDIO_DIR"
            audio=$((audio + 1))
            ;;
        videos)
            target_dir="$VIDEOS_DIR"
            videos=$((videos + 1))
            ;;
        ebooks)
            target_dir="$EBOOKS_DIR"
            ebooks=$((ebooks + 1))
            ;;
        documents)
            target_dir="$DOCUMENTS_DIR"
            documents=$((documents + 1))
            ;;
        *)
            target_dir="$MISC_DIR"
            misc=$((misc + 1))
            ;;
    esac

    if [ "$APPLY" -eq 0 ]; then
        printf '[%s] %s -> %s (%s)\n' "$category" "$path" "$target_dir" "$reason"
    else
        move_or_copy "$path" "$target_dir" "$reason"
    fi
done

progress "phase 2/2: handing PDFs to sort-pdfs"

sort_pdfs_args=(--source "$SOURCE_DIR" --dest "$DEST_DIR" --min-book-pages "$MIN_BOOK_PAGES" --min-paper-pages "$MIN_PAPER_PAGES" --max-paper-pages "$MAX_PAPER_PAGES")
if [ "$APPLY" -eq 1 ]; then
    sort_pdfs_args+=(--apply)
fi
if [ "$COPY_ONLY" -eq 1 ]; then
    sort_pdfs_args+=(--copy)
fi
if [ "$RECURSIVE" -eq 1 ]; then
    sort_pdfs_args+=(--recursive)
fi

PDF_SORT_TEXT_SAMPLE_PAGES="$TEXT_SAMPLE_PAGES" "$SORT_PDFS" "${sort_pdfs_args[@]}"

echo
printf 'Non-PDF summary: archives=%s images=%s audio=%s videos=%s ebooks=%s documents=%s misc=%s duplicates=%s\n' \
    "$archives" "$images" "$audio" "$videos" "$ebooks" "$documents" "$misc" "$duplicates"

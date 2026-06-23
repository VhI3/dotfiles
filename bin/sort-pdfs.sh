#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${PDF_SORT_SOURCE_DIR:-$HOME/Downloads/books-final}"
DEST_DIR="${PDF_SORT_DEST_DIR:-$SOURCE_DIR}"
MIN_BOOK_PAGES="${PDF_SORT_MIN_BOOK_PAGES:-80}"
MIN_PAPER_PAGES="${PDF_SORT_MIN_PAPER_PAGES:-4}"
MAX_PAPER_PAGES="${PDF_SORT_MAX_PAPER_PAGES:-60}"
TEXT_SAMPLE_PAGES="${PDF_SORT_TEXT_SAMPLE_PAGES:-1}"
TEXT_TIMEOUT_SECONDS="${PDF_SORT_TEXT_TIMEOUT_SECONDS:-8}"
APPLY=0
COPY_ONLY=0
RECURSIVE=0

usage() {
    cat <<'EOF'
Usage: sort-pdfs [--apply] [--copy] [--recursive] [--source DIR] [--dest DIR]
                 [--min-book-pages N] [--min-paper-pages N] [--max-paper-pages N]

Deduplicate PDFs first, then sort them into:
  books/
  theses/
  papers/
  others/
  duplicates/

Default behavior:
  - scan ~/Downloads/books-final
  - sort in place under category subfolders
  - dry run only

Examples:
  sort-pdfs
  sort-pdfs --source ~/Downloads/books-final --dest ~/Downloads/books-final
  sort-pdfs --source ~/Downloads/books-final --dest ~/Downloads/books-final --apply
  sort-pdfs --source ~/Downloads --dest ~/Downloads/pdf-library --recursive --apply
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
            echo "sort-pdfs: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "sort-pdfs: required command missing: $1" >&2
        exit 1
    }
}

need_cmd pdfinfo
need_cmd pdftotext
need_cmd sha256sum
need_cmd realpath

resolve_path() {
    realpath -m "$1"
}

lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

normalize_key() {
    lower "$1" | sed -E 's/[^a-z0-9]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+/_/g'
}

extract_field() {
    local key="$1"
    local info="$2"
    printf '%s\n' "$info" | awk -F: -v key="$key" '$1 == key {sub(/^[[:space:]]+/, "", $2); print $2; exit}'
}

count_members() {
    local data="${1:-}"
    if [ -z "$data" ]; then
        echo 0
    else
        printf '%s\n' "$data" | awk 'NF {count++} END {print count+0}'
    fi
}

append_group_member() {
    local key="$1"
    local member="$2"
    if [ -z "${GROUP_MEMBERS[$key]:-}" ]; then
        GROUP_MEMBERS[$key]="$member"
    else
        GROUP_MEMBERS[$key]+=$'\n'"$member"
    fi
}

progress() {
    printf '[sort-pdfs] %s\n' "$*" >&2
}

extract_pdf_text_sample() {
    local file="$1"
    local output=""
    local rc=0

    if command -v timeout >/dev/null 2>&1 && [ "${TEXT_TIMEOUT_SECONDS:-0}" -gt 0 ] 2>/dev/null; then
        output="$(timeout "${TEXT_TIMEOUT_SECONDS}s" pdftotext -f 1 -l "$TEXT_SAMPLE_PAGES" -nopgbrk -q -- "$file" - 2>/dev/null)" || rc=$?
    else
        output="$(pdftotext -f 1 -l "$TEXT_SAMPLE_PAGES" -nopgbrk -q -- "$file" - 2>/dev/null)" || rc=$?
    fi

    if [ "$rc" -ne 0 ]; then
        progress "text extraction skipped for $(basename "$file") (exit=$rc)"
    fi

    printf '%s' "$output" \
        | tr '[:upper:]' '[:lower:]' \
        | tr -cs '[:alnum:]' ' ' \
        | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

canonical_score() {
    local file="$1"
    local base base_lc score=0

    base="$(basename "$file")"
    base_lc="$(lower "$base")"

    if [ -n "${TITLE[$file]:-}" ]; then
        score=$((score + 4))
    fi
    if [ -n "${AUTHOR[$file]:-}" ]; then
        score=$((score + 2))
    fi
    if [ "${PAGES[$file]:-0}" -ge "$MIN_BOOK_PAGES" ] 2>/dev/null; then
        score=$((score + 1))
    fi
    if printf '%s' "$base_lc" | grep -Eq '(copy|duplicate|dup|scan|scanned|ocr|final|new|old|backup|\([0-9]+\)|-[0-9]+\.pdf$|_[0-9]+\.pdf$)'; then
        score=$((score - 3))
    fi
    if printf '%s' "$base_lc" | grep -Eq '(book|handbook|manual|guide|paper|thesis|dissertation)'; then
        score=$((score + 1))
    fi

    printf '%s\n' "$score"
}

pick_canonical() {
    local members="$1"
    local best="" best_score=-999999 candidate score

    while IFS= read -r candidate; do
        [ -n "$candidate" ] || continue
        score="$(canonical_score "$candidate")"
        if [ -z "$best" ] || [ "$score" -gt "$best_score" ]; then
            best="$candidate"
            best_score="$score"
        elif [ "$score" -eq "$best_score" ] && [ "${#candidate}" -lt "${#best}" ]; then
            best="$candidate"
            best_score="$score"
        fi
    done <<< "$members"

    printf '%s\n' "$best"
}

reason_append() {
    local current="$1"
    local extra="$2"
    if [ -z "$current" ]; then
        printf '%s\n' "$extra"
    else
        printf '%s,%s\n' "$current" "$extra"
    fi
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

SOURCE_DIR="$(resolve_path "$SOURCE_DIR")"
DEST_DIR="$(resolve_path "$DEST_DIR")"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "sort-pdfs: source directory not found: $SOURCE_DIR" >&2
    exit 1
fi

BOOKS_DIR="$DEST_DIR/books"
THESES_DIR="$DEST_DIR/theses"
PAPERS_DIR="$DEST_DIR/papers"
OTHERS_DIR="$DEST_DIR/others"
DUPLICATES_DIR="$DEST_DIR/duplicates"

declare -A TITLE=()
declare -A AUTHOR=()
declare -A PAGES=()
declare -A META_LC=()
declare -A TEXT_FLAGS=()
declare -A HASH_KEY=()
declare -A META_KEY=()
declare -A TEXT_KEY=()
declare -A GROUP_MEMBERS=()
declare -A DUPLICATE_OF=()
declare -A DUPLICATE_REASON=()

find_args=("$SOURCE_DIR")
if [ "$RECURSIVE" -eq 0 ]; then
    find_args+=(-maxdepth 1)
fi
find_args+=(-type f -iname '*.pdf')

if [[ "$DEST_DIR" == "$SOURCE_DIR" || "$DEST_DIR" == "$SOURCE_DIR/"* ]]; then
    find_args+=(
        ! -path "$BOOKS_DIR/*"
        ! -path "$THESES_DIR/*"
        ! -path "$PAPERS_DIR/*"
        ! -path "$OTHERS_DIR/*"
        ! -path "$DUPLICATES_DIR/*"
    )
fi

mapfile -t pdfs < <(find "${find_args[@]}" | sort)

if [ "${#pdfs[@]}" -eq 0 ]; then
    echo "sort-pdfs: no PDF files found in $SOURCE_DIR"
    exit 0
fi

progress "found ${#pdfs[@]} PDFs in $SOURCE_DIR"
progress "phase 1/3: scanning metadata and duplicate fingerprints"

scan_index=0
for pdf in "${pdfs[@]}"; do
    scan_index=$((scan_index + 1))
    progress "scanning $scan_index/${#pdfs[@]}: $(basename "$pdf")"

    info="$(pdfinfo "$pdf" 2>/dev/null || true)"
    title="$(extract_field "Title" "$info")"
    author="$(extract_field "Author" "$info")"
    subject="$(extract_field "Subject" "$info")"
    keywords="$(extract_field "Keywords" "$info")"
    pages="$(extract_field "Pages" "$info")"
    pages="${pages:-0}"

    base="$(basename "$pdf")"
    meta_lc="$(lower "$base $title $author $subject $keywords")"

    meta_key=""
    if [ -n "$title" ]; then
        meta_key="meta:$(normalize_key "$title|$author|$pages")"
    fi

    text_norm=""
    text_flags=""
    if [ "$pages" -le "$MAX_PAPER_PAGES" ] 2>/dev/null || [ -z "$meta_key" ]; then
        text_norm="$(extract_pdf_text_sample "$pdf")"

        if printf '%s' "$text_norm" | grep -Eq '(^| )abstract( |$)'; then
            text_flags="$(reason_append "$text_flags" "abstract")"
        fi
        if printf '%s' "$text_norm" | grep -Eq '(^| )(references|bibliography)( |$)'; then
            text_flags="$(reason_append "$text_flags" "references")"
        fi
        if printf '%s' "$text_norm" | grep -Eq '(^| )(doi|arxiv|proceedings|conference|journal|preprint|manuscript)( |$)'; then
            text_flags="$(reason_append "$text_flags" "paper-text")"
        fi
        if printf '%s' "$text_norm" | grep -Eq '(^| )(isbn|chapter|edition|publisher)( |$)'; then
            text_flags="$(reason_append "$text_flags" "book-text")"
        fi
    fi

    file_hash="$(sha256sum "$pdf" | awk '{print $1}')"
    hash_key="hash:$file_hash"

    text_key=""
    if [ "${#text_norm}" -ge 200 ] && [ "$pages" -ge 1 ] 2>/dev/null; then
        text_fp="$(printf '%s' "$text_norm" | cut -c1-12000 | sha256sum | awk '{print $1}')"
        text_key="text:${pages}:${text_fp}"
    fi

    TITLE["$pdf"]="$title"
    AUTHOR["$pdf"]="$author"
    PAGES["$pdf"]="$pages"
    META_LC["$pdf"]="$meta_lc"
    TEXT_FLAGS["$pdf"]="$text_flags"
    HASH_KEY["$pdf"]="$hash_key"
    META_KEY["$pdf"]="$meta_key"
    TEXT_KEY["$pdf"]="$text_key"

    append_group_member "$hash_key" "$pdf"
    if [ -n "$meta_key" ]; then
        append_group_member "$meta_key" "$pdf"
    fi
    if [ -n "$text_key" ]; then
        append_group_member "$text_key" "$pdf"
    fi
done

progress "phase 2/3: grouping duplicates"

for key in "${!GROUP_MEMBERS[@]}"; do
    [[ "$key" == hash:* ]] || continue
    members="${GROUP_MEMBERS[$key]}"
    if [ "$(count_members "$members")" -lt 2 ]; then
        continue
    fi

    canonical="$(pick_canonical "$members")"
    while IFS= read -r member; do
        [ -n "$member" ] || continue
        [ "$member" = "$canonical" ] && continue
        DUPLICATE_OF["$member"]="$canonical"
        DUPLICATE_REASON["$member"]="duplicate-hash=$(basename "$canonical")"
    done <<< "$members"
done

for key in "${!GROUP_MEMBERS[@]}"; do
    [[ "$key" == meta:* ]] || continue
    members="${GROUP_MEMBERS[$key]}"
    filtered=""

    while IFS= read -r member; do
        [ -n "$member" ] || continue
        [ -n "${DUPLICATE_OF[$member]:-}" ] && continue
        if [ -z "$filtered" ]; then
            filtered="$member"
        else
            filtered+=$'\n'"$member"
        fi
    done <<< "$members"

    if [ "$(count_members "$filtered")" -lt 2 ]; then
        continue
    fi

    canonical="$(pick_canonical "$filtered")"
    while IFS= read -r member; do
        [ -n "$member" ] || continue
        [ "$member" = "$canonical" ] && continue
        DUPLICATE_OF["$member"]="$canonical"
        DUPLICATE_REASON["$member"]="duplicate-metadata=$(basename "$canonical")"
    done <<< "$filtered"
done

for key in "${!GROUP_MEMBERS[@]}"; do
    [[ "$key" == text:* ]] || continue
    members="${GROUP_MEMBERS[$key]}"
    filtered=""

    while IFS= read -r member; do
        [ -n "$member" ] || continue
        [ -n "${DUPLICATE_OF[$member]:-}" ] && continue
        if [ -z "$filtered" ]; then
            filtered="$member"
        else
            filtered+=$'\n'"$member"
        fi
    done <<< "$members"

    if [ "$(count_members "$filtered")" -lt 2 ]; then
        continue
    fi

    canonical="$(pick_canonical "$filtered")"
    while IFS= read -r member; do
        [ -n "$member" ] || continue
        [ "$member" = "$canonical" ] && continue
        DUPLICATE_OF["$member"]="$canonical"
        DUPLICATE_REASON["$member"]="duplicate-text=$(basename "$canonical")"
    done <<< "$filtered"
done

classify_pdf() {
    local file="$1"
    local meta_lc text_flags pages book_score=0 thesis_score=0 paper_score=0 other_score=0
    local reasons=""

    meta_lc="${META_LC[$file]}"
    text_flags="${TEXT_FLAGS[$file]}"
    pages="${PAGES[$file]}"

    if printf '%s' "$meta_lc" | grep -Eq '(invoice|receipt|contract|bewerbung|cv|resume|certificate|zeugnis|formular|form|ticket|bill|statement)'; then
        other_score=$((other_score + 4))
        reasons="$(reason_append "$reasons" "document-keyword")"
    fi

    if [ "$pages" -ge "$MIN_BOOK_PAGES" ] 2>/dev/null; then
        book_score=$((book_score + 3))
        reasons="$(reason_append "$reasons" "pages=$pages")"
    elif [ "$pages" -ge $((MIN_BOOK_PAGES / 2)) ] 2>/dev/null; then
        book_score=$((book_score + 1))
    fi

    if printf '%s %s' "$meta_lc" "$text_flags" | grep -Eq '(book|ebook|handbook|manual|guide|textbook|workbook|novel|edition|isbn|publisher|book-text)'; then
        book_score=$((book_score + 2))
        reasons="$(reason_append "$reasons" "book-signal")"
    fi

    if printf '%s' "$meta_lc" | grep -Eq '(thesis|dissertation|master thesis|masters thesis|bachelor thesis|doctoral|doctorate|phd|ph\.d|habilitation|diplomarbeit|abschlussarbeit|submitted|fulfillment|fulfilment|advisor|supervisor|faculty|department|degree)'; then
        thesis_score=$((thesis_score + 4))
        reasons="$(reason_append "$reasons" "thesis-signal")"
    fi

    if [ "$pages" -ge 20 ] 2>/dev/null && printf '%s' "$meta_lc" | grep -Eq '(university|institute|faculty|department)'; then
        thesis_score=$((thesis_score + 1))
    fi

    if [ "$pages" -ge "$MIN_PAPER_PAGES" ] 2>/dev/null && [ "$pages" -le "$MAX_PAPER_PAGES" ] 2>/dev/null; then
        paper_score=$((paper_score + 1))
    fi

    if printf '%s %s' "$meta_lc" "$text_flags" | grep -Eq '(paper|article|journal|conference|proceedings|doi|arxiv|preprint|manuscript|paper-text|abstract|references)'; then
        paper_score=$((paper_score + 2))
        reasons="$(reason_append "$reasons" "paper-signal")"
    fi

    if [ -n "${AUTHOR[$file]}" ] && [ "$pages" -le "$MAX_PAPER_PAGES" ] 2>/dev/null; then
        paper_score=$((paper_score + 1))
    fi

    if [ "$other_score" -ge 4 ]; then
        printf 'others|%s\n' "$reasons"
        return 0
    fi
    if [ "$thesis_score" -ge 4 ]; then
        printf 'theses|%s\n' "$reasons"
        return 0
    fi
    if [ "$book_score" -ge 2 ] && [ "$book_score" -ge "$paper_score" ]; then
        printf 'books|%s\n' "$reasons"
        return 0
    fi
    if [ "$paper_score" -ge 2 ] && [ "$paper_score" -gt "$book_score" ]; then
        printf 'papers|%s\n' "$reasons"
        return 0
    fi

    printf 'others|%s\n' "${reasons:-unclassified}"
}

books=0
theses=0
papers=0
others=0
duplicates=0

progress "phase 3/3: classifying and planning moves"

for pdf in "${pdfs[@]}"; do
    if [ -n "${DUPLICATE_OF[$pdf]:-}" ]; then
        duplicates=$((duplicates + 1))
        reason="${DUPLICATE_REASON[$pdf]}"
        if [ "$APPLY" -eq 0 ]; then
            printf '[duplicate] %s -> %s (%s)\n' "$pdf" "$DUPLICATES_DIR" "$reason"
        else
            move_or_copy "$pdf" "$DUPLICATES_DIR" "$reason"
        fi
        continue
    fi

    classification="$(classify_pdf "$pdf")"
    category="${classification%%|*}"
    reason="${classification#*|}"
    case "$category" in
        books)
            books=$((books + 1))
            target_dir="$BOOKS_DIR"
            ;;
        theses)
            theses=$((theses + 1))
            target_dir="$THESES_DIR"
            ;;
        papers)
            papers=$((papers + 1))
            target_dir="$PAPERS_DIR"
            ;;
        *)
            others=$((others + 1))
            target_dir="$OTHERS_DIR"
            ;;
    esac

    if [ "$APPLY" -eq 0 ]; then
        printf '[%s] %s -> %s (%s)\n' "$category" "$pdf" "$target_dir" "$reason"
    else
        move_or_copy "$pdf" "$target_dir" "$reason"
    fi
done

echo
printf 'Summary: books=%s theses=%s papers=%s others=%s duplicates=%s\n' \
    "$books" "$theses" "$papers" "$others" "$duplicates"

if [ "$APPLY" -eq 0 ]; then
    echo
    echo "Dry run only. Re-run with --apply to perform the moves."
    echo "Use --copy if you want to keep the originals too."
    echo
    echo "Target folders:"
    echo "  $BOOKS_DIR"
    echo "  $THESES_DIR"
    echo "  $PAPERS_DIR"
    echo "  $OTHERS_DIR"
    echo "  $DUPLICATES_DIR"
fi

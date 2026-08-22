#!/usr/bin/env bash
set -euo pipefail

apply=0
recursive=1
target="."

usage() {
    cat <<'EOF'
Usage: clean-latex [--apply] [--current-dir-only] [path]

Remove common LaTeX build artifacts while keeping source files and PDFs.

Default:
  dry run on current directory and all subdirectories

Options:
  --apply      actually delete files
  --current-dir-only  search only the given directory
  -h, --help   show this help
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --apply)
            apply=1
            ;;
        --current-dir-only)
            recursive=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            target="$1"
            ;;
    esac
    shift
done

if [ ! -d "$target" ]; then
    echo "clean-latex: directory not found: $target" >&2
    exit 1
fi

depth_args=(-maxdepth 1)
if [ "$recursive" -eq 1 ]; then
    depth_args=()
fi

patterns=(
    "*.aux"
    "*.bbl"
    "*.bcf"
    "*.blg"
    "*.fdb_latexmk"
    "*.fls"
    "*.idx"
    "*.ilg"
    "*.ind"
    "*.lof"
    "*.log"
    "*.lot"
    "*.nav"
    "*.out"
    "*.run.xml"
    "*.snm"
    "*.synctex.gz"
    "*.toc"
    "*.vrb"
    "*.xdv"
)

find_args=("$target")
find_args+=("${depth_args[@]}")
find_args+=(-type f "(")

for i in "${!patterns[@]}"; do
    if [ "$i" -gt 0 ]; then
        find_args+=(-o)
    fi
    find_args+=(-name "${patterns[$i]}")
done

find_args+=(")")

mapfile -d '' files < <(find "${find_args[@]}" -print0 | sort -z)

if [ "${#files[@]}" -eq 0 ]; then
    echo "clean-latex: nothing to clean in $target"
    exit 0
fi

if [ "$apply" -eq 0 ]; then
    echo "clean-latex: dry run"
    printf '%s\n' "${files[@]}"
    echo
    echo "Run with --apply to delete these files."
    exit 0
fi

printf '%s\0' "${files[@]}" | xargs -0 rm -f
echo "clean-latex: removed ${#files[@]} file(s)"

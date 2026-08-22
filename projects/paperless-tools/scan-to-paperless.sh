#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
. "$SCRIPT_DIR/paperless-tools.lib.sh"
paperless_load_config

mode="${NAPS2_SCAN_MODE:-auto}"
duplex_source="${NAPS2_DUPLEX_SOURCE:-duplex}"
glass_source="${NAPS2_GLASS_SOURCE:-glass}"
glass_pages="${NAPS2_GLASS_PAGES:-2}"
dpi="${NAPS2_GLASS_DPI:-300}"
bitdepth="${NAPS2_GLASS_BITDEPTH:-color}"
pagesize="${NAPS2_GLASS_PAGESIZE:-a4}"
profile_name="${NAPS2_PROFILE_NAME:-}"
output_file=""

usage() {
    cat <<'EOF'
Usage:
  scan-to-paperless [options]

Smart Paperless scan helper.
Default mode tries the duplex feeder first. If that fails, it falls back to a
manual flatbed/glass scan.

Options:
      --mode VALUE         auto, duplex, glass, or profile (default: auto)
      --duplex-source VAL  NAPS2 feeder source for duplex mode (default: duplex)
  -n, --pages NUMBER       Number of manual glass scans in glass fallback (default: 2)
      --dpi NUMBER         Glass scan resolution (default: 300)
      --bitdepth VALUE     color, gray, or bw for glass scans (default: color)
      --pagesize VALUE     a4, letter, legal, etc. for glass scans (default: a4)
  -p, --profile NAME       NAPS2 profile name to use
  -o, --output FILE        Custom output PDF path
  -h, --help               Show this help

Examples:
  scan-to-paperless
  scan-to-paperless --mode glass
  scan-to-paperless --mode duplex
  scan-to-paperless --mode glass --pages 4
  scan-to-paperless --mode glass --bitdepth gray

Modes:
  auto     Try duplex feeder first, then glass if the feeder scan fails.
  duplex   Use the duplex feeder only.
  glass    Use the scanner glass only, waiting for Enter before each page.
  profile  Use the selected or most-recently-used NAPS2 profile without forcing
           source settings. This matches the older scan-to-paperless behavior.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --mode)
            mode="${2:-}"
            shift 2
            ;;
        --duplex-source)
            duplex_source="${2:-}"
            shift 2
            ;;
        -n|--pages)
            glass_pages="${2:-}"
            shift 2
            ;;
        --dpi)
            dpi="${2:-}"
            shift 2
            ;;
        --bitdepth)
            bitdepth="${2:-}"
            shift 2
            ;;
        --pagesize)
            pagesize="${2:-}"
            shift 2
            ;;
        -p|--profile)
            profile_name="${2:-}"
            shift 2
            ;;
        -o|--output)
            output_file="${2:-}"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

case "$mode" in
    auto|duplex|glass|profile) ;;
    *)
        echo "Error: --mode must be one of: auto, duplex, glass, profile." >&2
        exit 2
        ;;
esac

if ! [[ "$glass_pages" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: --pages must be a positive number." >&2
    exit 2
fi

if ! [[ "$dpi" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: --dpi must be a positive number." >&2
    exit 2
fi

timestamp="$(date '+%Y-%m-%d_%H-%M-%S')"
output_file="${output_file:-$PAPERLESS_CONSUME_DIR/scan_${timestamp}.pdf}"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/paperless-scan.XXXXXX")"
tmp_output="$tmp_dir/scan.pdf"

cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT

echo "==> Paperless scan helper"
echo "Mode:       $mode"
echo "Consume:    $PAPERLESS_CONSUME_DIR"
echo "Output:     $output_file"

ensure_consume_dir() {
    local dir="$PAPERLESS_CONSUME_DIR"
    local mount_point="${PAPERLESS_CONSUME_MOUNT:-}"
    local must_be_mounted="${PAPERLESS_CONSUME_MUST_BE_MOUNTED:-0}"
    local allow_create="${PAPERLESS_CONSUME_ALLOW_CREATE:-0}"

    if [ "$must_be_mounted" = "1" ]; then
        if [ -z "$mount_point" ]; then
            echo "Error: PAPERLESS_CONSUME_MUST_BE_MOUNTED=1 but PAPERLESS_CONSUME_MOUNT is empty." >&2
            exit 1
        fi

        if ! mountpoint -q "$mount_point"; then
            echo "Error: Paperless consume mount is not mounted: $mount_point" >&2
            echo "Hint: run mount-paperless-consume, then try scan-to-paperless again." >&2
            exit 1
        fi
    fi

    case "$dir" in
        /mnt/*|/media/*|/run/media/*)
            if [ ! -d "$dir" ] && [ "$allow_create" != "1" ]; then
                echo "Error: consume directory does not exist: $dir" >&2
                echo "Refusing to create a non-home consume path, to avoid scanning into a fake local mount." >&2
                echo "Hint: mount the server consume share first with mount-paperless-consume." >&2
                exit 1
            fi
            ;;
    esac

    mkdir -p "$dir"

    if [ ! -w "$dir" ]; then
        echo "Error: consume directory is not writable: $dir" >&2
        exit 1
    fi
}

ensure_consume_dir

if ! command -v naps2 >/dev/null 2>&1; then
    echo "Error: naps2 is not installed or not in PATH." >&2
    exit 1
fi

print_profile() {
    if [ -n "$profile_name" ]; then
        echo "Profile:    $profile_name"
    else
        echo "Profile:    most recently used GUI profile"
    fi
}

append_profile() {
    local -n cmd_ref="$1"
    if [ -n "$profile_name" ]; then
        cmd_ref+=(-p "$profile_name")
    fi
}

scan_profile() {
    local cmd=(
        naps2 console
        -o "$tmp_output"
        -v
        --disableocr
    )
    append_profile cmd

    echo "==> Starting scan with NAPS2 profile settings..."
    "${cmd[@]}"
}

scan_duplex() {
    local cmd=(
        naps2 console
        -o "$tmp_output"
        -v
        --source "$duplex_source"
        --disableocr
    )
    append_profile cmd

    echo "==> Trying duplex feeder scan..."
    echo "Source:     $duplex_source"
    "${cmd[@]}"
}

scan_glass() {
    local cmd=(
        naps2 console
        -o "$tmp_output"
        -v
        --source "$glass_source"
        -n "$glass_pages"
        --waitscan
        --pagesize "$pagesize"
        --dpi "$dpi"
        --bitdepth "$bitdepth"
        --deskew
        --disableocr
    )
    append_profile cmd

    echo "==> Falling back to scanner glass..."
    echo "Source:     $glass_source"
    echo "Pages:      $glass_pages"
    echo "Page size:  $pagesize"
    echo "DPI:        $dpi"
    echo "Bit depth:  $bitdepth"
    cat <<EOF

Manual glass workflow:
  1. Put the first side/page on the scanner glass.
  2. Press Enter when NAPS2 asks to start the scan.
  3. Flip or replace the page.
  4. Press Enter again for the next page.

Tip: scan pages in the final PDF order: front, back, next front, next back.

EOF

    "${cmd[@]}"
}

finish_scan() {
    if [ ! -s "$tmp_output" ]; then
        echo "Error: scan command finished but no non-empty PDF was created." >&2
        return 1
    fi

    mkdir -p "$(dirname "$output_file")"
    mv -f "$tmp_output" "$output_file"
    echo "==> Scan complete"
    echo "Saved PDF: $output_file"
    echo "Paperless will import it from the consume folder automatically."
}

print_profile

case "$mode" in
    profile)
        scan_profile
        finish_scan
        ;;
    duplex)
        scan_duplex
        finish_scan
        ;;
    glass)
        scan_glass
        finish_scan
        ;;
    auto)
        if scan_duplex && [ -s "$tmp_output" ]; then
            finish_scan
        else
            echo "==> Duplex feeder scan did not produce a PDF."
            echo "==> This usually means the feeder is empty; switching to glass mode."
            rm -f "$tmp_output"
            if ! scan_glass; then
                echo "Error: both duplex and glass scans failed. No file was imported into Paperless." >&2
                exit 1
            fi
            finish_scan
        fi
        ;;
esac

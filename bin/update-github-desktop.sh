#!/usr/bin/env bash
set -euo pipefail

API_URL="https://api.github.com/repos/shiftkey/desktop/releases/latest"
AUTO_YES=0

usage() {
    cat <<'EOF'
Usage: update-github-desktop [--yes]

Check GitHub Desktop from shiftkey/desktop and install the newest amd64 .deb
release when newer than the currently installed package.

Options:
  --yes       install automatically when an update is available
  -h, --help  show this help
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --yes|-y)
            AUTO_YES=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "update-github-desktop: unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

say() {
    printf '%s\n' "$*"
}

say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ {"

if ! dpkg-query -W -f='${Status}\n' github-desktop 2>/dev/null | grep -q "install ok installed"; then
    say "GitHub Desktop is not installed. Skipping."
    say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"
    exit 0
fi

for cmd in curl jq; do
    if ! have_cmd "$cmd"; then
        say "Missing dependency: $cmd"
        say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"
        exit 1
    fi
done

installed_version="$(dpkg-query -W -f='${Version}\n' github-desktop 2>/dev/null | head -n1)"

release_json="$(curl -fsSL "$API_URL")"
latest_tag="$(printf '%s' "$release_json" | jq -r '.tag_name // empty')"
latest_version="${latest_tag#release-}"
latest_version="${latest_version#v}"

if [ -z "$latest_version" ]; then
    say "Could not determine latest GitHub Desktop version."
    say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"
    exit 1
fi

download_url="$(
    printf '%s' "$release_json" \
    | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url' \
    | grep -E '/(linux|Linux)?.*amd64.*\.deb$|/GitHubDesktop-linux-amd64-.*\.deb$|/github-desktop-.*amd64\.deb$' \
    | head -n1
)"

if [ -z "$download_url" ]; then
    download_url="$(
        printf '%s' "$release_json" \
        | jq -r '.assets[] | select(.name | endswith(".deb")) | .browser_download_url' \
        | head -n1
    )"
fi

if [ -z "$download_url" ]; then
    say "Could not find a downloadable .deb asset for GitHub Desktop."
    say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"
    exit 1
fi

say "Latest Version: $latest_version"
say "Installed Version: $installed_version"

if dpkg --compare-versions "$installed_version" ge "$latest_version"; then
    say "GitHub Desktop is up to date."
    say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"
    exit 0
fi

say "A newer version of GitHub Desktop is available."

if [ "$AUTO_YES" -ne 1 ]; then
    read -r -p "Install GitHub Desktop $latest_version now? [y/N] " response
    case "$response" in
        [Yy]|[Yy][Ee][Ss]) ;;
        *)
            say "Update cancelled."
            say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"
            exit 0
            ;;
    esac
fi

tmpdir="$(mktemp -d)"
cleanup() {
    rm -rf "$tmpdir"
}
trap cleanup EXIT

deb_file="$tmpdir/$(basename "$download_url")"

say "Downloading GitHub Desktop $latest_version..."
curl -fL "$download_url" -o "$deb_file"

if have_cmd nala; then
    say "Installing with nala..."
    sudo nala install -y "$deb_file"
else
    say "Installing with apt..."
    sudo apt install -y "$deb_file"
fi

say "GitHub Desktop updated successfully."
say "--------🅥 🅗 🅘 ➌------ᴳⁱᵗᴴᵘᵇ------ }"

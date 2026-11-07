#!/usr/bin/env bash
set -euo pipefail

API_URL="https://api.github.com/repos/dariogriffo/ghostty-debian/releases/latest"
RELEASE_PREFIX="https://github.com/dariogriffo/ghostty-debian/releases/download/"
auto_yes=0
install_missing=0
check_only=0
prepare_only=0
tmpdir=""

usage() {
    cat <<'EOF'
Usage: update-ghostty [--yes] [--install] [--check | --prepare]

Update the installed Ghostty from free dariogriffo/ghostty-debian GitHub releases.
The package must match this machine's Debian/Ubuntu release and architecture.

Options:
  --yes, -y  Install an available update without prompting.
  --install  Also install Ghostty if it is not installed (fresh Debian setup).
  --check    Show installed/release versions without changing anything.
  --prepare  Only disable the subscription APT sources and update their pins.
  -h, --help Show this help.
EOF
}

die() {
    printf 'update-ghostty: %s\n' "$*" >&2
    exit 1
}

as_root() {
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

prepare_apt() {
    local script_dir
    script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
    bash "$script_dir/protect-neovim-appimage.sh"
}

cleanup() {
    if [ -n "$tmpdir" ]; then
        rm -rf -- "$tmpdir"
    fi
}
trap cleanup EXIT

while [ "$#" -gt 0 ]; do
    case "$1" in
        --yes|-y) auto_yes=1 ;;
        --install) install_missing=1 ;;
        --check) check_only=1 ;;
        --prepare) prepare_only=1 ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
done

if [ "$check_only" -eq 1 ] && [ "$prepare_only" -eq 1 ]; then
    die "--check and --prepare cannot be combined"
fi
if [ "$prepare_only" -eq 1 ]; then
    prepare_apt
    exit 0
fi

for cmd in curl jq dpkg dpkg-query dpkg-deb sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || die "missing dependency: $cmd (install curl, jq, dpkg and coreutils)"
done

installed_version="none"
if [ "$(dpkg-query -W -f='${Status}' ghostty 2>/dev/null || true)" = "install ok installed" ]; then
    installed_version="$(dpkg-query -W -f='${Version}' ghostty)"
fi
if [ "$installed_version" = "none" ] && [ "$install_missing" -eq 0 ] && [ "$check_only" -eq 0 ]; then
    echo "Ghostty is not installed. Skipping (use update-ghostty --install to install it)."
    exit 0
fi

. /etc/os-release
case "${ID:-}" in
    debian|ubuntu) suite="${VERSION_CODENAME:-}" ;;
    *) die "unsupported distribution: ${ID:-unknown}; select a compatible package manually" ;;
esac
[[ "$suite" =~ ^[a-z]+$ ]] || die "cannot determine this distribution's release codename"
architecture="$(dpkg --print-architecture)"
case "$architecture" in
    amd64|arm64) ;;
    *) die "unsupported architecture: $architecture" ;;
esac

if ! release_json="$(curl -fsSL --proto '=https' --proto-redir '=https' --retry 2 --connect-timeout 15 --max-time 60 "$API_URL")"; then
    die "could not check GitHub releases; check your connection or GitHub API rate limit, then retry"
fi
if ! asset_json="$(printf '%s' "$release_json" | jq -ce --arg suite "$suite" --arg arch "$architecture" '
    [.assets[]? | select(
        (.name | startswith("ghostty_")) and
        ((.name | endswith("~" + $suite + "_" + $arch + ".deb")) or
         (.name | endswith("." + $suite + "_" + $arch + ".deb")))
    )] | if length == 1 then .[0] else empty end
')"; then
    die "no unique Ghostty package for $suite/$architecture in the latest release; keeping the installed version"
fi

asset_name="$(printf '%s' "$asset_json" | jq -r '.name')"
download_url="$(printf '%s' "$asset_json" | jq -r '.browser_download_url')"
digest="$(printf '%s' "$asset_json" | jq -r '.digest // empty')"
[[ "$asset_name" =~ ^ghostty_[A-Za-z0-9.+~_-]+\.deb$ ]] || die "unexpected package filename"
[[ "$download_url" == "$RELEASE_PREFIX"* ]] || die "unexpected package download host"
[[ "$digest" =~ ^sha256:[a-fA-F0-9]{64}$ ]] || die "GitHub did not publish a SHA-256 digest; refusing an unverified download"

# GitHub asset names use .trixie, while the embedded Debian version uses ~trixie.
latest_version="${asset_name#ghostty_}"
latest_version="${latest_version%_${architecture}.deb}"
latest_version="${latest_version%.${suite}}~${suite}"
# Older releases already used ~<suite> in their asset names.
if [[ "$asset_name" == *"~${suite}_${architecture}.deb" ]]; then
    latest_version="${asset_name#ghostty_}"
    latest_version="${latest_version%_${architecture}.deb}"
fi
dpkg --validate-version "$latest_version" || die "invalid package version: $latest_version"

printf 'Ghostty installed: %s\nGitHub package:    %s (%s/%s)\n' "$installed_version" "$latest_version" "$suite" "$architecture"
if [ "$check_only" -eq 1 ]; then
    exit 0
fi

prepare_apt
if [ "$installed_version" != "none" ] && dpkg --compare-versions "$installed_version" ge "$latest_version"; then
    echo "Ghostty is up to date."
    exit 0
fi

if [ "$auto_yes" -ne 1 ]; then
    read -r -p "Install Ghostty $latest_version? [y/N] " response
    case "$response" in
        [Yy]|[Yy][Ee][Ss]) ;;
        *) echo "Ghostty update cancelled."; exit 0 ;;
    esac
fi

tmpdir="$(mktemp -d /tmp/update-ghostty.XXXXXXXX)"
# APT's _apt user needs to be able to read the local archive.
chmod 0755 "$tmpdir"
deb_file="$tmpdir/$asset_name"
printf 'Downloading %s from GitHub...\n' "$asset_name"
if ! curl -fL --proto '=https' --proto-redir '=https' --retry 2 --connect-timeout 15 --max-time 300 "$download_url" -o "$deb_file"; then
    die "download failed; the installed Ghostty has not been changed"
fi
printf '%s  %s\n' "${digest#sha256:}" "$deb_file" | sha256sum --check --status || die "package checksum mismatch; refusing installation"
chmod 0644 "$deb_file"

[ "$(dpkg-deb -f "$deb_file" Package)" = "ghostty" ] || die "downloaded archive is not the ghostty package"
[ "$(dpkg-deb -f "$deb_file" Architecture)" = "$architecture" ] || die "package architecture mismatch"
[ "$(dpkg-deb -f "$deb_file" Version)" = "$latest_version" ] || die "package version mismatch"

echo "Checksum and package metadata verified. Installing with APT..."
as_root apt-get install --no-remove -y "$deb_file" || die "APT installation failed; resolve the reported dependency or package error and retry"
[ "$(dpkg-query -W -f='${Status}' ghostty)" = "install ok installed" ] || die "Ghostty was not fully configured"
[ "$(dpkg-query -W -f='${Version}' ghostty)" = "$latest_version" ] || die "the installed version does not match the requested update"
printf 'Ghostty %s installed successfully.\n' "$latest_version"

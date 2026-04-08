#!/bin/bash
set -euo pipefail

# Octave is built from source because:
# - Debian's apt version often lags behind
# - Source build enables JIT compilation (--enable-jit)
# - Installs to ~/.opt/octave to avoid polluting system dirs

DEFAULT_OCTAVE_VERSION="11.1.0"
INSTALL_DIR="$HOME/.opt/octave"
OCTAVE_DOWNLOAD_PAGE="https://octave.org/download"
OCTAVE_MIRROR_BASE="https://ftpmirror.gnu.org/octave"
OCTAVE_INSTALL_MODE="${OCTAVE_INSTALL_MODE:-source}"
OCTAVE_FORCE_REBUILD="${OCTAVE_FORCE_REBUILD:-0}"

APT_OCTAVE_PACKAGES=(
    octave
    octave-control
    octave-image
    octave-io
    octave-optim
    octave-signal
    octave-statistics
    octave-symbolic
    python3-sympy
)

fetch_latest_octave_version() {
    local page version

    for page in "$OCTAVE_DOWNLOAD_PAGE" "https://octave.org/"; do
        version="$(
            wget -qO- "$page" 2>/dev/null \
                | tr '\n' ' ' \
                | grep -Eo 'latest stable release[^0-9]*[0-9]+\.[0-9]+\.[0-9]+|GNU Octave [0-9]+\.[0-9]+\.[0-9]+ Released' \
                | head -n1 \
                | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' \
                | head -n1 || true
        )"

        if [ -n "$version" ]; then
            printf '%s\n' "$version"
            return 0
        fi
    done

    return 1
}

installed_octave_version() {
    if [ -x "$INSTALL_DIR/bin/octave" ]; then
        "$INSTALL_DIR/bin/octave" --version 2>/dev/null \
            | awk 'NR == 1 { print $4 }'
    fi
}

DETECTED_OCTAVE_VERSION="$(fetch_latest_octave_version || true)"
OCTAVE_VERSION="${OCTAVE_VERSION:-${DETECTED_OCTAVE_VERSION:-$DEFAULT_OCTAVE_VERSION}}"
INSTALLED_VERSION="$(installed_octave_version || true)"

if [ "$OCTAVE_INSTALL_MODE" = "apt" ]; then
    echo "==> [08] Octave — fast apt mode"
    sudo apt install -y "${APT_OCTAVE_PACKAGES[@]}"
    echo "==> [08] Done."
    exit 0
fi

if [ "$OCTAVE_INSTALL_MODE" != "source" ]; then
    echo "Unsupported OCTAVE_INSTALL_MODE: $OCTAVE_INSTALL_MODE"
    echo "Use OCTAVE_INSTALL_MODE=source or OCTAVE_INSTALL_MODE=apt"
    exit 1
fi

echo "==> [08] Octave $OCTAVE_VERSION — dependencies"
sudo apt install -y \
    g++ gfortran make \
    libblas-dev liblapack-dev libopenblas-dev \
    libreadline-dev libncurses5-dev \
    libcurl4-gnutls-dev libfftw3-dev \
    libgl1-mesa-dev libglu1-mesa-dev libpng-dev libz-dev \
    libfltk1.3-dev libqhull-dev libhdf5-dev \
    libgraphicsmagick++1-dev libqrupdate-dev \
    libarpack2-dev libsundials-dev \
    libqscintilla2-qt5-dev libglpk-dev \
    libbz2-dev icoutils rapidjson-dev portaudio19-dev \
    qttools5-dev qttools5-dev-tools \
    build-essential python3 python3-sympy wget ca-certificates xz-utils

echo "==> [08] SymPy (required for Octave symbolic package)"
python3 -c "import sympy" >/dev/null 2>&1

echo "==> [08] Octave $OCTAVE_VERSION — build & install to $INSTALL_DIR"
if [ "$OCTAVE_FORCE_REBUILD" = "1" ] || [ "$INSTALLED_VERSION" != "$OCTAVE_VERSION" ]; then
    if [ -n "$INSTALLED_VERSION" ]; then
        echo "    Installed version: $INSTALLED_VERSION"
        if [ "$OCTAVE_FORCE_REBUILD" = "1" ]; then
            echo "    Rebuilding Octave $OCTAVE_VERSION with current dependencies"
        else
            echo "    Upgrading to:      $OCTAVE_VERSION"
        fi
    fi

    mkdir -p "$INSTALL_DIR"
    wget -q "$OCTAVE_MIRROR_BASE/octave-${OCTAVE_VERSION}.tar.xz" \
        -O "/tmp/octave-${OCTAVE_VERSION}.tar.xz"
    tar -xf "/tmp/octave-${OCTAVE_VERSION}.tar.xz" -C /tmp
    cd "/tmp/octave-${OCTAVE_VERSION}"
    ./configure --prefix="$INSTALL_DIR" --enable-jit
    make -j"$(nproc)"
    make install
    rm -rf "/tmp/octave-${OCTAVE_VERSION}" "/tmp/octave-${OCTAVE_VERSION}.tar.xz"
    cd -

    # Add to PATH in bashrc if not already there
    if ! grep -q "\.opt/octave" "$HOME/.bashrc"; then
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    fi
else
    echo "    Octave $OCTAVE_VERSION already installed at $INSTALL_DIR, skipping build."
fi

echo "==> [08] Octave packages — symbolic, control, image, io, optim, signal, statistics"
for package in symbolic control image io optim signal statistics; do
    "$INSTALL_DIR/bin/octave" --eval "pkg install -forge $package" 2>/dev/null || true
done

echo "==> [08] Done."

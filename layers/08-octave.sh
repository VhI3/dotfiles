#!/bin/bash
set -euo pipefail

# Octave is built from source because:
# - Debian's apt version (8.x) lags behind
# - Source build enables JIT compilation (--enable-jit)
# - Installs to ~/.opt/octave to avoid polluting system dirs

OCTAVE_VERSION="9.3.0"
INSTALL_DIR="$HOME/.opt/octave"

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
    build-essential python3 python3-pip

echo "==> [08] SymPy (required for Octave symbolic package)"
python3 -m pip install --user sympy

echo "==> [08] Octave $OCTAVE_VERSION — build & install to $INSTALL_DIR"
if [ ! -f "$INSTALL_DIR/bin/octave" ]; then
    mkdir -p "$INSTALL_DIR"
    wget -q "https://ftp.gnu.org/gnu/octave/octave-${OCTAVE_VERSION}.tar.gz" \
        -O "/tmp/octave-${OCTAVE_VERSION}.tar.gz"
    tar -xzf "/tmp/octave-${OCTAVE_VERSION}.tar.gz" -C /tmp
    cd "/tmp/octave-${OCTAVE_VERSION}"
    ./configure --prefix="$INSTALL_DIR" --enable-jit
    make -j"$(nproc)"
    make install
    rm -rf "/tmp/octave-${OCTAVE_VERSION}" "/tmp/octave-${OCTAVE_VERSION}.tar.gz"
    cd -

    # Add to PATH in bashrc if not already there
    if ! grep -q "\.opt/octave" "$HOME/.bashrc"; then
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    fi
else
    echo "    Octave already installed at $INSTALL_DIR, skipping build."
fi

echo "==> [08] Octave packages — symbolic, statistics"
"$INSTALL_DIR/bin/octave" --eval "pkg install -forge symbolic" 2>/dev/null || true
"$INSTALL_DIR/bin/octave" --eval "pkg install -forge statistics" 2>/dev/null || true

echo "==> [08] Done."

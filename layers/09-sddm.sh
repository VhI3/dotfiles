#!/bin/bash
set -euo pipefail

echo "==> [09] SDDM theme"
# Catppuccin SDDM theme
# Upstream: https://github.com/catppuccin/sddm
# Usage:
#   ./layers/09-sddm.sh
#   SDDM_THEME_FLAVOUR=macchiato SDDM_THEME_ACCENT=blue ./layers/09-sddm.sh

THEME_FLAVOUR="${SDDM_THEME_FLAVOUR:-mocha}"
THEME_ACCENT="${SDDM_THEME_ACCENT:-mauve}"

case "$THEME_FLAVOUR" in
    latte|frappe|macchiato|mocha) ;;
    *)
        echo "    ERROR: invalid SDDM_THEME_FLAVOUR '$THEME_FLAVOUR'" >&2
        echo "    Choose one of: latte, frappe, macchiato, mocha" >&2
        exit 1
        ;;
esac

case "$THEME_ACCENT" in
    rosewater|flamingo|pink|mauve|red|maroon|peach|yellow|green|teal|sky|sapphire|blue|lavender) ;;
    *)
        echo "    ERROR: invalid SDDM_THEME_ACCENT '$THEME_ACCENT'" >&2
        echo "    Choose one of: rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender" >&2
        exit 1
        ;;
esac

THEME_NAME="catppuccin-${THEME_FLAVOUR}-${THEME_ACCENT}"
ARCHIVE_URL="https://github.com/catppuccin/sddm/releases/latest/download/${THEME_NAME}-sddm.zip"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "    Installing SDDM and Catppuccin dependencies..."
sudo apt install -y --no-install-recommends \
    sddm \
    unzip \
    qml-module-qtquick-layouts \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-window2 \
    libqt6svg6

echo "    Downloading ${THEME_NAME}..."
curl -fsSL -o "$TMP_DIR/${THEME_NAME}.zip" "$ARCHIVE_URL"
unzip -q "$TMP_DIR/${THEME_NAME}.zip" -d "$TMP_DIR"

if [ ! -d "$TMP_DIR/$THEME_NAME" ]; then
    echo "    ERROR: theme source not found after unzip: $TMP_DIR/$THEME_NAME" >&2
    exit 1
fi

sudo mkdir -p /usr/share/sddm/themes
sudo rm -rf "$THEME_DIR"
sudo mv "$TMP_DIR/$THEME_NAME" "$THEME_DIR"

echo "    Configuring SDDM theme..."
if [ -f /etc/sddm.conf ]; then
    awk -v theme="$THEME_NAME" '
        BEGIN {
            in_theme = 0
            theme_done = 0
        }
        /^\[Theme\]$/ {
            in_theme = 1
            print
            next
        }
        /^\[/ {
            if (in_theme && !theme_done) {
                print "Current=" theme
                theme_done = 1
            }
            in_theme = 0
        }
        {
            if (in_theme && /^Current=/) {
                if (!theme_done) {
                    print "Current=" theme
                    theme_done = 1
                }
                next
            }
            print
        }
        END {
            if (!theme_done) {
                if (!in_theme) {
                    print "[Theme]"
                }
                print "Current=" theme
            }
        }
    ' /etc/sddm.conf > "$TMP_DIR/sddm.conf"
    sudo cp "$TMP_DIR/sddm.conf" /etc/sddm.conf
else
    sudo mkdir -p /etc/sddm.conf.d
    cat > "$TMP_DIR/99-catppuccin-theme.conf" <<EOF
[Theme]
Current=${THEME_NAME}
EOF
    sudo cp "$TMP_DIR/99-catppuccin-theme.conf" /etc/sddm.conf.d/99-catppuccin-theme.conf
fi

echo "    Theme set to ${THEME_NAME}."
echo "    Note: upstream recommends running the SDDM greeter on Wayland if the theme renders incorrectly on X11."
echo "==> [09] Done."

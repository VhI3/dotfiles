#!/bin/bash

# Step 3: Add Debian Testing Repositories
if ! grep -q "testing" /etc/apt/sources.list; then
  echo "Adding Debian Testing Repositories..."
  tee -a /etc/apt/sources.list >/dev/null <<EOL
deb http://deb.debian.org/debian testing main contrib non-free
deb-src http://deb.debian.org/debian testing main contrib non-free
EOL
  echo "Configuring package priorities..."
  tee /etc/apt/preferences.d/testing >/dev/null <<EOL
Package: *
Pin: release a=stable
Pin-Priority: 700

Package: *
Pin: release a=testing
Pin-Priority: 650
EOL
fi

# Step 4: Update and Upgrade System
echo "Updating and upgrading system..."
apt update && apt upgrade -y && apt autoremove -y

# Step 5: Install Essential Tools
echo "Installing essential tools..."
sudo apt install -y build-essential xserver-xorg-core xinit xserver-xorg-input-libinput x11-xserver-utils i3 git wget curl python3 python3-venv python3-pip ninja-build cmake xinput cargo xclip libfuse2 jq
# For installing the alacritty
sudo pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev

# Step 6: Configure Trackpad Tapping
echo "Configuring trackpad tapping..."
mkdir -p /etc/X11/xorg.conf.d
tee /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null <<EOL
Section "InputClass"
    Identifier "libinput touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOL

# Step 7: Configure .xinitrc for i3
if [ ! -f ~/.xinitrc ]; then
  echo "Creating ~/.xinitrc to start i3..."
  echo "exec i3" >~/.xinitrc
else
  echo "Ensuring ~/.xinitrc launches i3..."
  grep -q "exec i3" ~/.xinitrc || echo "exec i3" >>~/.xinitrc
fi

# Step 8: Configure Auto-Start for i3
if [ ! -f ~/.bash_profile ]; then
  echo "Creating ~/.bash_profile for auto-start of i3..."
  cat <<EOF >~/.bash_profile
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
EOF
else
  echo "Ensuring ~/.bash_profile includes auto-start for i3..."
  grep -q "exec startx" ~/.bash_profile || cat <<EOF >>~/.bash_profile

if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
EOF
fi

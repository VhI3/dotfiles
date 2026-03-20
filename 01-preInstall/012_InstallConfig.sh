#!/bin/bash

# Step 4: Configure Trackpad Tapping
echo "Configuring trackpad tapping..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null <<EOL
Section "InputClass"
    Identifier "libinput touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOL

# Step 5: Configure .xinitrc for i3
if [ ! -f ~/.xinitrc ]; then
    echo "Creating ~/.xinitrc to start i3..."
    echo "exec i3" > ~/.xinitrc
else
    echo "Ensuring ~/.xinitrc launches i3..."
    grep -q "exec i3" ~/.xinitrc || echo "exec i3" >> ~/.xinitrc
fi

# Step 6: Configure Auto-Start for i3
if [ ! -f ~/.bash_profile ]; then
    echo "Creating ~/.bash_profile for auto-start of i3..."
    cat <<EOF >~/.bash_profile
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    exec dbus-launch startx
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

# Final Message
echo "Installation and configuration complete! Reboot your system to apply changes."
read -p "Do you want to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    sudo reboot
else
    echo "Please log out and log back in for changes to take effect."
fi

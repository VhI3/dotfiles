#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)."
fi

# Step 1: Install Required Packages
echo "Installing required packages..."
sudo apt update && sudo apt install -y dunst libnotify-bin

# Step 2: Create Udev Rule for Backlight Permissions
echo "Creating Udev rule for backlight permissions..."
echo 'ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chmod 0666 /sys/class/backlight/intel_backlight/brightness"' | sudo tee /etc/udev/rules.d/90-backlight.rules

# Reload Udev Rules
echo "Reloading Udev rules..."
sudo udevadm control --reload-rules && sudo udevadm trigger

# Step 3: Manually Set Brightness File Permissions
echo "Setting brightness file permissions..."
sudo chmod 0666 /sys/class/backlight/intel_backlight/brightness

# # Step 4: Create Brightness Script
# echo "Creating brightness control script..."
# mkdir -p ~/dotfiles
# cat << 'EOF' > ~/dotfiles/brightness.sh
# #!/bin/bash
#
# brightness_file="/sys/class/backlight/intel_backlight/brightness"
# max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
#
# if [[ "$1" == "up" ]]; then
#   current=$(cat $brightness_file)
#   new=$((current + max_brightness / 10))
#   [ "$new" -gt "$max_brightness" ] && new=$max_brightness
#   echo $new > $brightness_file
# elif [[ "$1" == "down" ]]; then
#   current=$(cat $brightness_file)
#   new=$((current - max_brightness / 10))
#   [ "$new" -lt 1 ] && new=1
#   echo $new > $brightness_file
# fi
#
# # Calculate brightness percentage
# brightness_percent=$((new * 100 / max_brightness))
#
# # Show notification using dunstify
# dunstify -r 91190 -u low "Brightness: $brightness_percent%" -h int:value:$brightness_percent
# EOF
#

# Create a symbolic link in ~/.local/bin
echo "Creating symbolic link for brightness script..."
mkdir -p ~/.local/bin
ln -sf ~/dotfiles/brightness.sh ~/.local/bin/brightness

# Make the script executable
echo "Making brightness script executable..."
chmod +x ~/dotfiles/brightness.sh

# # Step 5: Add i3 Keybindings for Brightness Control
# echo "Adding brightness keybindings to i3 config..."
# mkdir -p ~/.config/i3
# grep -qxF 'bindsym XF86MonBrightnessUp exec ~/.local/bin/brightness up' ~/.config/i3/config || echo 'bindsym XF86MonBrightnessUp exec ~/.local/bin/brightness up' >> ~/.config/i3/config
# grep -qxF 'bindsym XF86MonBrightnessDown exec ~/.local/bin/brightness down' ~/.config/i3/config || echo 'bindsym XF86MonBrightnessDown exec ~/.local/bin/brightness down' >> ~/.config/i3/config
# grep -qxF 'exec --no-startup-id dunst' ~/.config/i3/config || echo 'exec --no-startup-id dunst' >> ~/.config/i3/config
#
# Step 6: Reload i3 Configuration
echo "Reloading i3 configuration..."
i3-msg reload

# Final Message
echo "Brightness control setup is complete!"

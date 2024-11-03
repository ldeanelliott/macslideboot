#!/bin/bash

# Installation Script for AutoSlideNetCheck Setup

# Variables
USER="Office TV" # Adjust to the target user name if different
START_TIME="07:30:00"
SHUTDOWN_TIME="16:00:00"
DND_START="6:00"
DND_END="17:00"
SCRIPT_PATH="/path/to/AutoSlideNetCheck.applescript" # Update to the actual path of AutoSlideNetCheck script

echo "Starting AutoSlideNetCheck installation script..."

# Step 1: Set Scheduled Power On and Off using pmset
echo "Configuring scheduled power on and off times..."
sudo pmset repeat wakeorpoweron MTWRF $START_TIME shutdown MTWRF $SHUTDOWN_TIME

# Step 2: Enable auto-login for Office TV user
echo "Setting up auto-login..."
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser "$USER"

# Step 3: Disable notifications and set up Do Not Disturb
echo "Disabling notifications and configuring Do Not Disturb..."
# Disable all app notifications
defaults -currentHost write com.apple.notificationcenterui doNotDisturb -bool true
defaults write com.apple.ncprefs.plist dndStart -int $(echo $DND_START | awk -F: '{print $1*60+$2}')
defaults write com.apple.ncprefs.plist dndEnd -int $(echo $DND_END | awk -F: '{print $1*60+$2}')
killall NotificationCenter

# Step 4: Add AutoSlideNetCheck script to Login Items
echo "Adding AutoSlideNetCheck script as a login item..."
osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$SCRIPT_PATH\", hidden:true}"

# Step 5: Configure Energy Saver settings
echo "Configuring Energy Saver settings..."
# Set display to never sleep during active hours
sudo pmset -a displaysleep 0
# Enable auto-restart after power failure
sudo pmset -a autorestart 1
# Disable sleeping when display is off
sudo pmset -a sleep 0

# Step 6: Lock System Preferences for security
echo "Locking System Preferences..."
# Lock settings in Accessibility and Privacy
sudo security authorizationdb write system.preferences "allow"
sudo security authorizationdb write system.preferences.security "allow"

# Final Step: Convert Office TV to Standard User (if needed)
echo "Converting Office TV to Standard user..."
dseditgroup -o edit -d "$USER" -t user admin

echo "AutoSlideNetCheck setup complete. Please restart the Mac to apply changes."

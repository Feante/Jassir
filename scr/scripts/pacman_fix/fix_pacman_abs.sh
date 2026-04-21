#!/bin/bash
# fix_pacman_abs.sh

echo "Restoring pacman using ABS..."

# Download fresh pacman config from Arch Build System
cd /tmp
git clone https://aur.archlinux.org/pacman.git
cd pacman

# Extract default configuration
makepkg -f
cd ..

# Install extracted config
tar -xzf pacman.tar.gz --wildcards 'etc/*'

# Set permissions
chmod 644 /etc/pacman.conf
chmod 644 /etc/pacman.d/mirrorlist

# Verify
sudo pacman -Sy

echo "✓ ABS restoration complete"


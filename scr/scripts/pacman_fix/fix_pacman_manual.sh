#!/bin/bash
# fix_pacman_manual.sh

echo "Manual pacman restoration..."

# Remove corrupted config
rm -f /etc/pacman.conf /etc/pacman.d/mirrorlist

# Download fresh configuration
wget https://raw.githubusercontent.com/archlinux/pacman/master/pacman.conf -O /etc/pacman.conf
wget https://archlinux.org/pacman/mirrorlist -O /etc/pacman.d/mirrorlist

# Set proper permissions
chmod 644 /etc/pacman.conf
chmod 644 /etc/pacman.d/mirrorlist

# Refresh database
sudo pacman -Sy

echo "✓ Pacman restored manually"


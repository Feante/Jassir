#!/bin/bash
# fix_pacman.sh - Restore pacman configuration

echo "=============================================="
echo "  FIXING PACMAN CONFIGURATION"
echo "=============================================="

# Backup current config
echo "Backing up current configuration..."
cp -n /etc/pacman.conf /etc/pacman.conf.backup
cp -n /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Restore default pacman configuration
echo "Restoring default pacman configuration..."
curl -o /etc/pacman.conf https://archlinux.org/pacman/pacman.default-mirrorlist-64.conf
curl -o /etc/pacman.d/mirrorlist https://archlinux.org/pacman/mirrorlist

# Verify restoration
echo ""
echo "Checking pacman configuration..."
cat /etc/pacman.conf | head -20

# Test connection
echo ""
echo "Testing repository connection..."
sudo pacman -Sy

echo "=============================================="
echo "  VERIFICATION"
echo "=============================================="

# Verify pacman is working
echo ""
echo "Pacman version:"
pacman -V

echo ""
echo "Available repositories:"
pacman -Qg

echo ""
echo "=============================================="
echo "  NEXT STEPS"
echo "=============================================="
echo ""
echo "Run your Jarvis installation again:"
echo "  ./install_dependencies.sh"
echo ""


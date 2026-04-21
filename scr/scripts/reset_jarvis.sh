#!/bin/bash
# reset_jarvis.sh - Completely wipe JARVIS installation for a fresh start

set -e

echo "=============================================="
echo "  JARVIS - COMPLETE UNINSTALL/RESET"
echo "=============================================="
echo "WARNING: This will delete:"
echo "  - All application code in ~/.jassir/app"
echo "  - The Python virtual environment in ~/.jassir/venv"
echo "  - All downloaded models in ~/.jassir/models"
echo "  - All configuration files in ~/.jassir/config"
echo ""
read -p "Are you absolutely sure you want to proceed? (y/N) " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Reset cancelled."
    exit 0
fi

echo ""
echo "Cleaning up..."

JASSIR_ROOT="$HOME/.jassir"

if [ -d "$JASSIR_ROOT" ]; then
    echo "  Removing $JASSIR_ROOT..."
    rm -rf "$JASSIR_ROOT"
    echo "  ✓ Cleaned up Jassir root directory"
else
    echo "  - No existing installation found at $JASSIR_ROOT"
fi

# Optional: Clean up temporary install logs or artifacts if any
# rm -rf ~/jarvis_install_tmp

echo ""
echo "=============================================="
echo "  ✓ JARVIS has been completely reset."
echo "=============================================="
echo "To re-install, run the following from your jarvis directory:"
echo "  ./scr/scripts/install_dependencies.sh"
echo "  ./scr/scripts/download_models.sh"
echo "  ./scr/scripts/install_app.sh"
echo "=============================================="

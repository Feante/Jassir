#!/bin/bash
# setup.sh - JARVIS Main Installer (Hardware-Adaptive)

set -e

echo "=============================================="
echo "  JARVIS - FULL SYSTEM INSTALLATION"
echo "=============================================="

# 1. Hardware Scan
echo ">>> Step 1: Scanning Hardware..."
chmod +x scr/scripts/hardware_scan.sh
bash scr/scripts/hardware_scan.sh

# 2. Dependencies (will use hardware profile for ROCm/CUDA choice)
echo ">>> Step 2: Installing Dependencies..."
chmod +x scr/scripts/install_dependencies.sh
bash scr/scripts/install_dependencies.sh

# 3. Download Models (optimized for detected profile)
echo ">>> Step 3: Downloading Optimized Models..."
chmod +x scr/scripts/download_models.sh
bash scr/scripts/download_models.sh

# 4. Install App Code
echo ">>> Step 4: Installing Application Source..."
chmod +x scr/scripts/install_app.sh
bash scr/scripts/install_app.sh

# 5. Create Launcher
echo ">>> Step 5: Creating Launchers..."
chmod +x scr/scripts/create_launcher.sh
bash scr/scripts/create_launcher.sh

# 6. Verify
echo ">>> Step 6: Verifying Installation..."
chmod +x scr/scripts/verify_install.sh
bash scr/scripts/verify_install.sh

echo "=============================================="
echo "  INSTALLATION COMPLETE!"
echo "  You can now start JARVIS by typing: jassir"
echo "=============================================="

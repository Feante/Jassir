#!/bin/bash
# install_preparation.sh - System Preparation

set -e

echo "=============================================="
echo "  JARVIS INSTALLATION - SYSTEM PREPARATION"
echo "=============================================="

# Check architecture
echo "✓ Architecture: $(uname -m)"

# Check available RAM
echo "✓ Available RAM: $(free -h +g | awk '/Mem:/ {print $2}')"

# Check GPU
if command -v rocm-smi &> /dev/null; then
    echo "✓ ROCm detected: $(rocm-smi | grep 'Name:' | head -1)"
else
    echo "⚠ ROCm not detected - installing..."
    sudo pacman -S rocm-llvm rocm-opencl rocm-hcc
fi

# Check Python
echo "✓ Python version: $(python --version)"

# Create installation directory
INSTALL_DIR="$HOME/.jassir"
mkdir -p "$INSTALL_DIR"/{models,logs,config,bin}

echo ""
echo "✓ Installation directory: $INSTALL_DIR"


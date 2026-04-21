#!/bin/bash
# install_rocm_fix.sh

echo "=============================================="
echo "  FIXING ROCM INSTALLATION"
echo "=============================================="

# Update package database
echo "Updating package database..."
sudo pacman -Sy

# Remove any partial ROCm installations
echo "Cleaning previous ROCm installations..."
sudo pacman -Rns --noconfirm rocm* 2>/dev/null || true

# Install ROCm packages (multiple versions for compatibility)
echo "Installing ROCm packages..."
sudo pacman -S --needed \
    rocm \
    rocm-clr \
    rocm-hip-clr \
    rocm-llvm \
    rocm-hip \
    rocm-gfx1151-bin

# Install additional ROCm components
echo "Installing additional ROCm components..."
sudo pacman -S --needed \
    rocm-opencl \
    rocm-hipcc \
    rocm-validation-tools

# Set up environment variables
echo ""
echo "Setting up ROCm environment..."
cat >> ~/.bashrc << 'EOF'

# ROCm Environment Setup
export ROCM_HOME=/opt/rocm
export PATH=$ROCM_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ROCM_HOME/lib:$LD_LIBRARY_PATH
EOF

# Apply the new PATH for the rest of this script
export ROCM_HOME=/opt/rocm
export PATH="$ROCM_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$ROCM_HOME/lib:${LD_LIBRARY_PATH:-}"

echo "=============================================="
echo "  VERIFICATION"
echo "=============================================="

# Verify ROCm installation (non-fatal — informational only)
echo "Checking ROCm installation..."
if command -v rocm-smi &>/dev/null; then
    rocm-smi || true
else
    echo "  ⚠ rocm-smi not found (ROCm may not be fully installed)"
fi

echo ""
echo "Checking HIP installation..."
if command -v hipcc &>/dev/null; then
    hipcc --version
else
    echo "  ⚠ hipcc not found in PATH"
    echo "    Expected at: $ROCM_HOME/bin/hipcc"
    echo "    This is normal if the ROCm HIP compiler package isn't installed."
    echo "    llama.cpp only needs the HIP runtime libraries, not the compiler."
fi

echo ""
echo "Checking LLVM installation..."
if command -v llvm-config &>/dev/null; then
    llvm-config --version
else
    echo "  ⚠ llvm-config not found (check that rocm-llvm is installed)"
fi

echo ""
echo "=============================================="
echo "  INSTALLATION COMPLETE"
echo "=============================================="
echo ""
echo "  ℹ  Open a NEW terminal or run 'source ~/.bashrc'"
echo "     for the ROCm PATH changes to take effect."

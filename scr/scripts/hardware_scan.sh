#!/bin/bash
# hardware_scan.sh - Auto-detect hardware for JARVIS optimization

echo "=============================================="
echo "  JARVIS - HARDWARE AUTO-SCAN"
echo "=============================================="

# Detect GPU
GPU_VENDOR="unknown"
VRAM_GB=0

if lspci | grep -i "nvidia" > /dev/null; then
    GPU_VENDOR="nvidia"
    if command -v nvidia-smi &> /dev/null; then
        VRAM_GB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1 | awk '{print int($1/1024)}')
    fi
elif lspci | grep -i "amd" > /dev/null || lspci | grep -i "ati" > /dev/null; then
    GPU_VENDOR="amd"
    # Try to get AMD VRAM (requires rocm-smi or just estimate from lspci)
    if command -v rocm-smi &> /dev/null; then
        VRAM_GB=$(rocm-smi --showmeminfo vram --json | grep -oP '"total": \d+' | head -n 1 | grep -oP '\d+' | awk '{print int($1/1024/1024/1024)}')
    else
        # Fallback estimation for 7800 XT if not detected
        VRAM_GB=16
    fi
elif lspci | grep -i "intel" > /dev/null; then
    GPU_VENDOR="intel"
    VRAM_GB=4
fi

# Detect RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')

# Detect CPU Cores
CPU_CORES=$(nproc)

echo "Detected Hardware:"
echo "  - GPU Vendor: $GPU_VENDOR"
echo "  - VRAM: ${VRAM_GB}GB"
echo "  - System RAM: ${RAM_GB}GB"
echo "  - CPU Cores: $CPU_CORES"

# Determine Model Profile
PROFILE="medium"
if [ $VRAM_GB -ge 16 ]; then
    PROFILE="ultra" # For RX 7800 XT / RTX 4080+
elif [ $VRAM_GB -ge 8 ]; then
    PROFILE="high"
elif [ $VRAM_GB -ge 4 ]; then
    PROFILE="medium"
else
    PROFILE="low"
fi

echo "Recommended Profile: $PROFILE"

# Save to config
mkdir -p "$HOME/.jassir/config"
cat <<EOF > "$HOME/.jassir/config/hardware.json"
{
    "gpu_vendor": "$GPU_VENDOR",
    "vram_gb": $VRAM_GB,
    "ram_gb": $RAM_GB,
    "cpu_cores": $CPU_CORES,
    "profile": "$PROFILE",
    "last_scan": "$(date)"
}
EOF

echo "✓ Hardware config saved to ~/.jassir/config/hardware.json"

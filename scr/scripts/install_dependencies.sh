#!/bin/bash
# install_dependencies.sh - Hardware-Adaptive Dependency Installer

set -e

CONFIG_FILE="$HOME/.jassir/config/hardware.json"
GPU_VENDOR="amd"
if [ -f "$CONFIG_FILE" ]; then
    GPU_VENDOR=$(grep -oP '"gpu_vendor": "\K[^"]+' "$CONFIG_FILE")
fi

echo "=============================================="
echo "  JARVIS INSTALLATION - DEPENDENCIES ($GPU_VENDOR)"
echo "=============================================="

VENV_PATH="$HOME/.jassir/venv"

# 1. System packages
echo "Installing system packages..."
sudo pacman -Sy --needed --noconfirm \
    git cmake ninja base-devel clang lld python python-pip \
    wget curl jq portaudio espeak-ng alsa-utils ffmpeg

# 2. GPU Specific System Packages
if [ "$GPU_VENDOR" == "amd" ]; then
    sudo pacman -S --needed --noconfirm rocm-llvm || true
elif [ "$GPU_VENDOR" == "nvidia" ]; then
    sudo pacman -S --needed --noconfirm cuda || true
fi

# 3. Virtual Environment
if [ -d "$VENV_PATH" ]; then rm -rf "$VENV_PATH"; fi
python -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"

echo "Installing Python base packages..."
pip install --upgrade pip setuptools wheel
pip install --no-cache-dir psutil pydub speechrecognition pyttsx3 \
    langchain langchain-community sentence-transformers fastapi \
    uvicorn websockets aiohttp aiofiles python-multipart pyaudio \
    streamlit faster-whisper soundfile

# 4. Hardware-Specific llama-cpp-python
echo "Installing hardware-optimized llama-cpp-python..."
if [ "$GPU_VENDOR" == "nvidia" ]; then
    CMAKE_ARGS="-DLLAMA_CUDA=ON" FORCE_CMAKE=1 pip install --no-cache-dir llama-cpp-python
elif [ "$GPU_VENDOR" == "amd" ]; then
    export ROCM_HOME=/opt/rocm
    export PATH=$ROCM_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$ROCM_HOME/lib:$LD_LIBRARY_PATH
    CMAKE_ARGS="-DLLAMA_HIPBLAS=ON" FORCE_CMAKE=1 pip install --no-cache-dir llama-cpp-python
else
    # Fallback to Vulkan for multi-vendor support if requested, or just CPU
    CMAKE_ARGS="-DLLAMA_VULKAN=ON" FORCE_CMAKE=1 pip install --no-cache-dir llama-cpp-python
fi

pip install --no-cache-dir torch
deactivate

echo "✓ Dependencies installed for $GPU_VENDOR"

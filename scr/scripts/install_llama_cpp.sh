#!/bin/bash
# install_llama_cpp.sh - Install llama.cpp using CMake

set -e

echo "=============================================="
echo "  JARVIS INSTALLATION - LLAMA.CPP (CMAKE)"
echo "=============================================="

# Clone repository
echo "Cloning llama.cpp..."
LLAMA_DIR="$HOME/.jassir/llama.cpp"
mkdir -p "$LLAMA_DIR"
cd "$LLAMA_DIR"

git clone --recursive https://github.com/ggml-org/llama.cpp.git
cd llama.cpp

# Configure with CMake + Ninja generator
echo "Configuring with CMake..."
mkdir -p build
cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$HOME/.jassir/llama" \
    -DLLAMA_BUILD_TESTING=OFF \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    -DLLAMA_BUILD_BENCHMARKS=OFF \
    -DLLAMA_METAL=OFF \
    -DLLAMA_CUDA=OFF \
    -DLLAMA_HIPBLAS=ON \
    -DLLAMA_BLAS=OFF \
    -DLLAMA_NATIVE=ON \
    ..

# Build with Ninja for speed
echo "Building with Ninja..."
ninja -j$(nproc)

# Install binaries
echo "Installing binaries..."
ninja install

echo ""
echo "✓ llama.cpp installed to: $HOME/.jassir/llama"
echo "✓ Binary location: $HOME/.jassir/llama/bin/llama-cli"


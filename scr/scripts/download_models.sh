#!/bin/bash
# download_models.sh - Hardware-optimized model downloader

set -e

CONFIG_FILE="$HOME/.jassir/config/hardware.json"
PROFILE="medium"
if [ -f "$CONFIG_FILE" ]; then
    PROFILE=$(grep -oP '"profile": "\K[^"]+' "$CONFIG_FILE")
fi

echo "=============================================="
echo "  JARVIS - MODEL DOWNLOAD (Profile: $PROFILE)"
echo "=============================================="

MODELS_DIR="$HOME/.jassir/models"
BIN_DIR="$HOME/.jassir/bin"
mkdir -p "$MODELS_DIR/tts"
mkdir -p "$BIN_DIR"

download_file() {
    local url=$1; local name=$2; local path=$3
    if [ -f "$path" ]; then echo "  ✓ $name exists"; return 0; fi
    echo "Downloading: $name..."
    wget -q --show-progress "$url" -O "$path"
}

# --- 1. LLM Models based on Hardware Profile ---
echo ""
echo "Selecting best models for your $PROFILE profile..."

case $PROFILE in
    "ultra")
        # 14B models for 16GB+ VRAM (RX 7800 XT)
        REASONER_URL="https://huggingface.co/bartowski/Qwen2.5-14B-Instruct-GGUF/resolve/main/Qwen2.5-14B-Instruct-Q4_K_M.gguf?download=true"
        FAST_URL="https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf?download=true"
        ;;
    "high")
        # 9B + 3B models for 8GB-12GB VRAM
        REASONER_URL="https://huggingface.co/Jackrong/Qwen3.5-9B-Gemini-3.1-Pro-Reasoning-Distill-GGUF/resolve/main/Qwen3.5-9B.Q6_K.gguf?download=true"
        FAST_URL="https://huggingface.co/bartowski/Qwen2.5-3B-Instruct-GGUF/resolve/main/Qwen2.5-3B-Instruct-Q6_K.gguf?download=true"
        ;;
    *)
        # 7B + 1.5B models for lower specs
        REASONER_URL="https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf?download=true"
        FAST_URL="https://huggingface.co/bartowski/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/Qwen2.5-1.5B-Instruct-Q6_K.gguf?download=true"
        ;;
esac

download_file "$REASONER_URL" "reasoner.gguf" "$MODELS_DIR/reasoner.gguf"
download_file "$FAST_URL" "fast.gguf" "$MODELS_DIR/fast.gguf"

# --- 2. Piper TTS & Voices (REVERTED TO FIRST VOICE) ---
echo ""
echo "Installing Piper TTS and Voices..."

# Piper Engine
if [ ! -f "$BIN_DIR/piper-tts" ]; then
    wget -q "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz" -O "/tmp/piper.tar.gz"
    mkdir -p "$BIN_DIR/piper_temp"
    tar -xzf "/tmp/piper.tar.gz" -C "$BIN_DIR/piper_temp"
    cp -r "$BIN_DIR/piper_temp/piper/"* "$BIN_DIR/"
    mv "$BIN_DIR/piper" "$BIN_DIR/piper-tts"
    rm -rf "$BIN_DIR/piper_temp" "/tmp/piper.tar.gz"
fi

# English Voice (Lessac)
download_file "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium/en_US-lessac-medium.onnx?download=true" "en_US-lessac-medium.onnx" "$MODELS_DIR/tts/en_US-lessac-medium.onnx"
download_file "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json?download=true" "en_US-lessac-medium.onnx.json" "$MODELS_DIR/tts/en_US-lessac-medium.onnx.json"

# German Voice (Thorsten - First voice requested)
download_file "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx?download=true" "de_DE-thorsten-high.onnx" "$MODELS_DIR/tts/de_DE-thorsten-high.onnx"
download_file "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx.json?download=true" "de_DE-thorsten-high.onnx.json" "$MODELS_DIR/tts/de_DE-thorsten-high.onnx.json"

echo "✓ All models and binaries verified"

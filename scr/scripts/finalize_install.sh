#!/bin/bash
# finalize_install.sh - Final configuration and validation

set -e

echo "=============================================="
echo "  JARVIS INSTALLATION - FINALIZATION"
echo "=============================================="

# Create config directory
mkdir -p "$HOME/.jassir/config"

# Default configuration
cat > "$HOME/.jassir/config/jassir.json" << 'CONFIG_EOF'
{
  "model_path": "./models/llama-2-13b-chat.Q8_0.gguf",
  "context_window": 16384,
  "n_gpu_layers": 80,
  "n_threads": 8,
  "use_rocm": true,
  "temperature": 0.7,
  "max_tokens": 1024,
  "vault_path": "./obsidian_vault",
  "auto_save_logs": true,
  "log_level": "INFO"
}
CONFIG_EOF

# Create aliases
cat >> ~/.bashrc << 'ALIASES_EOF'

# JARVIS Aliases
alias jassir="source ~/.jassir/venv/bin/activate && python ~/.jassir/bin/jassir.py"
alias jassir-web="source ~/.jassir/venv/bin/activate && streamlit run ~/.jassir/app/web_interface.py"
ALIASES_EOF

cat >> ~/.zshrc << 'ALIASES_EOF'

# JARVIS Aliases
alias jassir="source ~/.jassir/venv/bin/activate && python ~/.jassir/bin/jassir.py"
ALIASES_EOF

echo "✓ Configuration complete"
echo "✓ Aliases added to ~/.bashrc and ~/.zshrc"


# <img src="assets/logo.png" width="48" height="48" valign="middle"> Jassir - Autonomous Desktop Assistant

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://www.linux.org/)
[![Hardware: AMD ROCm / NVIDIA CUDA](https://img.shields.io/badge/hardware-ROCm%20%7C%20CUDA-orange.svg)](https://github.com/ggerganov/llama.cpp)

**Jassir** is a powerful, locally-hosted, and fully autonomous desktop AI assistant. Designed for privacy and high performance, Jassir leverages state-of-the-art LLMs (up to 14B parameters) to manage your files, answer complex queries, and even check the weather—all while running 100% on your local hardware.

---

## 🚀 Key Features

### 🧠 Intelligence & Memory
- **Dual-Model Orchestration**: Swaps between a high-power **Reasoner** (Qwen 14B) and a **Fast Helper** (Qwen 7B) based on task complexity.
- **Hardware-Adaptive**: Automatically scans your hardware (GPU, VRAM, RAM) and selects the best model profile for your setup.
- **Persistent Memory**: AI conversation history stored locally in `~/.jassir/AI_save`.

### 🎙️ Multi-lingual Voice Interface
- **Zero-Internet Voice**: Local STT via **Faster-Whisper** and TTS via **Piper**.
- **Auto-Language Detection**: Supports **English** and **German** with native voice models.
- **Hands-Free Activation**: Use "Hey Jassir" to wake up your assistant.

### 🛠️ Autonomous System Tools
- **File Management**: Create, move, or delete files using natural language.
- **Weather Integration**: Real-time weather reports via Open-Meteo.
- **Obsidian RAG**: Integration with your Obsidian vault for personalized knowledge retrieval.

---

## 📦 Installation

### Option 1: Automated Installation (Recommended)
We provide a hardware-adaptive setup script that automates the entire deployment.
```bash
git clone https://github.com/yourusername/jassir.git
cd jassir
chmod +x setup.sh
./setup.sh
```

### Option 2: Manual Installation (Step-by-Step)
If you prefer to set up Jassir manually, you can run the individual scripts located in `scr/scripts/` in the following order:

#### 1. Hardware Scanning
Detect your hardware and create the initial configuration:
```bash
bash scr/scripts/hardware_scan.sh
```
This creates `~/.jassir/config/hardware.json`.

#### 2. Install Dependencies
Install system packages and set up the Python virtual environment:
```bash
bash scr/scripts/install_dependencies.sh
```

#### 3. Download Models
Download the LLM and TTS models based on your hardware profile:
```bash
bash scr/scripts/download_models.sh
```

#### 4. Deploy Application
Install the Jassir core logic and voice interface:
```bash
bash scr/scripts/install_app.sh
```

#### 5. Create Launchers
Set up the `jassir` command and launcher scripts:
```bash
bash scr/scripts/create_launcher.sh
```

#### 6. Finalize & Verify
Finalize the installation and run verification tests:
```bash
bash scr/scripts/finalize_install.sh
bash scr/scripts/verify_install.sh
```

---

## 🎮 Usage

Jassir is controlled primarily through the `jassir` command.

### Launching the Assistant
```bash
jassir                # Start voice-operated mode (default)
jassir --console      # Start text-only console interface
jassir --web          # Launch modern Web UI (Streamlit)
jassir --benchmark    # Run performance benchmarks
```

### Voice Commands Examples
- *"Hey Jassir, create a folder named 'ProjectX' on my desktop."*
- *"Jassir, wie ist das Wetter heute in Berlin?"*
- *"Explain the latest notes in my Obsidian vault about AI."*

---

## 🏗️ Architecture

- **LLM Engine**: `llama-cpp-python` (Hardware-accelerated).
- **STT**: `faster-whisper` (running locally).
- **TTS**: `Piper` (optimized ONNX runtime).
- **Storage**: Local JSON-based memory bank and local GGUF models.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="center">
  <i>Built for the local-first AI future.</i>
</p>


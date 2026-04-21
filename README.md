# <img src="assets/logo.png" width="48" height="48" valign="middle"> JARVIS - Autonomous Desktop Assistant

[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey.svg)](https://www.linux.org/)
[![Hardware: AMD ROCm / NVIDIA CUDA](https://img.shields.io/badge/hardware-ROCm%20%7C%20CUDA-orange.svg)](https://github.com/ggerganov/llama.cpp)

**JARVIS** is a powerful, locally-hosted, and fully autonomous desktop AI assistant. Designed for privacy and high performance, JARVIS leverages state-of-the-art LLMs (up to 14B parameters) to manage your files, answer complex queries, and even check the weather—all while running 100% on your local hardware.

---

## 🚀 Key Features

### 🧠 Intelligence & Memory
- **Dual-Model Orchestration**: Swaps between a high-power **Reasoner** (Qwen 14B) and a **Fast Helper** (Qwen 7B) based on task complexity.
- **Hardware-Adaptive**: Automatically scans your hardware (GPU, VRAM, RAM) and selects the best model profile for your setup (optimized for high-end cards like the **RX 7800 XT**).
- **AI_save Memory Bank**: Persistent conversation history stored locally. JARVIS remembers your past interactions across restarts.

### 🎙️ Multi-lingual Voice Interface
- **Zero-Internet Voice**: High-performance local STT via **Faster-Whisper** and TTS via **Piper**.
- **Auto-Language Detection**: Automatically detects if you are speaking **English** or **German** and responds with the appropriate native voice model.
- **Hands-Free Activation**: Use "Hey Jarvis" or "Jassir" to wake up your assistant.

### 🛠️ Autonomous System Tools
- **File System Management**: Create, edit, move, or delete files and folders using natural language.
- **Weather Forecasts**: Integrated Open-Meteo tool for real-time weather reports without needing API keys.
- **Obsidian RAG**: Deep integration with your Obsidian vault for personalized knowledge retrieval.

---

## 🛠️ Requirements & Support

JARVIS is built for **Arch Linux** and optimized for hardware acceleration.

| Component | Minimum | Recommended (Ultra) |
| :--- | :--- | :--- |
| **GPU** | 4GB VRAM (Any) | **16GB VRAM (RX 7800 XT / RTX 4080)** |
| **RAM** | 8GB | 32GB |
| **CPU** | 4 Cores | **Ryzen 7 9800X3D (8+ Cores)** |
| **OS** | Linux (Arch/Ubuntu) | Arch Linux |

---

## 📦 Installation

We provide a hardware-adaptive setup script that automates the entire deployment.

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/jarvis.git
cd jarvis
```

### 2. Run the Universal Installer
The installer will scan your hardware and automatically configure the best GPU backend (**ROCm** for AMD or **CUDA** for NVIDIA).
```bash
chmod +x setup.sh
./setup.sh
```

---

## 🎮 Usage

JARVIS is controlled primarily through the `jassir` command.

### Launching the Assistant
```bash
jassir                # Standard terminal interface
jassir --voice        # Hands-free voice mode (STT/TTS)
jassir --web          # Modern Web UI (Streamlit)
```

### Voice Commands Examples
- *"Hey Jarvis, create a folder named 'ProjectX' on my desktop."*
- *"Jarvis, wie ist das Wetter heute in Berlin?"*
- *"Explain the latest notes in my Obsidian vault about AI."*
- *"Move the file 'data.csv' into the 'Archive' folder."*

---

## 🏗️ Architecture

- **LLM Engine**: `llama-cpp-python` (with HIPBLAS/CUDA/Vulkan support).
- **Speech-to-Text**: `faster-whisper` (running on CPU/GPU).
- **Text-to-Speech**: `Piper` (optimized ONNX runtime).
- **System Logic**: Python 3.12+ with hardware-aware orchestration.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  <i>Built for the local-first AI future.</i>
</p>

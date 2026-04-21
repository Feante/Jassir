#!/bin/bash
# install_app.sh - Deploy JARVIS Application Source

set -e

APP_DIR="$HOME/.jassir/app"
BIN_DIR="$HOME/.jassir/bin"
mkdir -p "$APP_DIR" "$BIN_DIR"

echo "Deploying Jassir Core..."
cat << 'PYEOF' > "$APP_DIR/jassir_core.py"
"""
Jarvis Core - Hardware-Optimized AI Integration (Adaptive)
"""
import os
import sys
import json
import shutil
import urllib.request
from typing import Dict, List, Optional
from datetime import datetime

class JarvisCore:
    def __init__(self):
        self.config = self._load_config()
        self._setup_gpu_environment()
        self.reasoner_llm = None
        self.fast_llm = None
        self.knowledge_base = None
        self.initialized = False
        self.memory_dir = os.path.expanduser("~/.jassir/AI_save")
        os.makedirs(self.memory_dir, exist_ok=True)
        self.history = self._load_memory()

    def _setup_gpu_environment(self):
        if self.config.get("use_rocm", True):
            rocm_home = "/opt/rocm"
            if os.path.exists(rocm_home):
                os.environ["ROCM_HOME"] = rocm_home
                os.environ["HSA_OVERRIDE_GFX_VERSION"] = "10.3.0"
                print(f"✓ GPU Environment: ROCm Enabled")
        
    def _load_config(self) -> Dict:
        default_config = {
            "reasoner_path": os.path.expanduser("~/.jassir/models/reasoner.gguf"),
            "fast_path": os.path.expanduser("~/.jassir/models/fast.gguf"),
            "context_window": 8192,
            "n_gpu_layers": 99,
            "use_rocm": True,
            "max_tokens": 512,
        }
        return default_config

    def _load_memory(self) -> List:
        path = os.path.join(self.memory_dir, "history.json")
        if os.path.exists(path):
            try:
                with open(path, 'r') as f: return json.load(f)
            except: pass
        return []

    def _save_memory(self):
        path = os.path.join(self.memory_dir, "history.json")
        with open(path, 'w') as f: json.dump(self.history[-50:], f, indent=2)
    
    def initialize_llm(self):
        from llama_cpp import Llama
        print("  ⏳ Loading Models...")
        try:
            if os.path.exists(self.config["reasoner_path"]):
                self.reasoner_llm = Llama(model_path=self.config["reasoner_path"], n_ctx=self.config["context_window"], n_gpu_layers=self.config["n_gpu_layers"], verbose=False)
            if os.path.exists(self.config["fast_path"]):
                self.fast_llm = Llama(model_path=self.config["fast_path"], n_ctx=2048, n_gpu_layers=self.config["n_gpu_layers"], verbose=False)
            self.initialized = True
            print("  ✓ Models Ready")
        except Exception as e: print(f"  ✗ Model Error: {e}")
        return self.initialized

    def query(self, prompt: str) -> str:
        if not self.initialized: return "Error: Models not initialized"
        llm = self.reasoner_llm if len(prompt) > 100 else (self.fast_llm or self.reasoner_llm)
        system = "You are Jarvis, a helpful assistant. Keep answers concise for voice."
        formatted = f"<|im_start|>system\n{system}<|im_end|>\n"
        for msg in self.history[-5:]: formatted += f"<|im_start|>{msg['role']}\n{msg['content']}<|im_end|>\n"
        formatted += f"<|im_start|>user\n{prompt}<|im_end|>\n<|im_start|>assistant\n"
        
        try:
            res = llm(formatted, max_tokens=self.config["max_tokens"], stop=["<|im_end|>"], echo=False)
            answer = res['choices'][0]['text'].strip()
            self.history.append({"role": "user", "content": prompt})
            self.history.append({"role": "assistant", "content": answer})
            self._save_memory()
            return answer
        except Exception as e: return f"Error: {e}"

jassir = JarvisCore()
PYEOF

echo "Deploying Voice Interface..."
cat << 'PYEOF' > "$APP_DIR/voice_interface.py"
import os, time, subprocess, tempfile, wave
import numpy as np, pyaudio
from faster_whisper import WhisperModel
from jassir_core import jassir

class VoiceInterface:
    WAKE_WORDS = ["jarvis", "jassir", "hey jarvis"]
    MODEL_EN = os.path.expanduser("~/.jassir/models/tts/en_US-lessac-medium.onnx")
    MODEL_DE = os.path.expanduser("~/.jassir/models/tts/de_DE-thorsten-high.onnx")
    PIPER_EXE = os.path.expanduser("~/.jassir/bin/piper-tts")

    def __init__(self):
        print("  ⏳ Initializing Voice...")
        self.stt = WhisperModel("base", device="cpu", compute_type="int8")
        self.pa = pyaudio.PyAudio()
        self._running = False

    def speak(self, text, lang="en"):
        if not text.strip(): return
        print(f"\n  Jarvis: {text}")
        model = self.MODEL_DE if lang == "de" else self.MODEL_EN
        if not os.path.exists(model): model = self.MODEL_EN
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            path = tmp.name
        env = os.environ.copy()
        env["LD_LIBRARY_PATH"] = os.path.dirname(self.PIPER_EXE)
        cmd = [self.PIPER_EXE, "--model", model, "--output_file", path]
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, env=env)
        p.communicate(input=text.encode('utf-8'))
        if p.returncode == 0: subprocess.run(["aplay", "-q", path])
        if os.path.exists(path): os.remove(path)

    def listen(self):
        CHUNK, RATE = 1024, 16000
        stream = self.pa.open(format=pyaudio.paInt16, channels=1, rate=RATE, input=True, frames_per_buffer=CHUNK)
        frames, started, silent = [], False, 0
        print("  [Listening...]      ", end="\r")
        while True:
            data = stream.read(CHUNK, exception_on_overflow=False)
            frames.append(data)
            energy = np.abs(np.frombuffer(data, dtype=np.int16)).mean()
            if energy > 250:
                if not started: print("  [Recording...]      ", end="\r")
                started, silent = True, 0
            elif started: silent += 1
            if started and silent > 30: break
        stream.stop_stream(); stream.close()
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            wf = wave.open(tmp.name, 'wb')
            wf.setnchannels(1); wf.setsampwidth(2); wf.setframerate(RATE)
            wf.writeframes(b''.join(frames)); wf.close()
            path = tmp.name
        segments, info = self.stt.transcribe(path)
        text = " ".join([s.text for s in segments]).strip().lower()
        if os.path.exists(path): os.remove(path)
        return text, info.language

    def run(self):
        self._running = True
        if not jassir.initialized: jassir.initialize_llm()
        self.speak("Jarvis online.")
        while self._running:
            try:
                text, lang = self.listen()
                if not text: continue
                print(f"  🗣️  You ({lang}): {text}")
                response = jassir.query(text)
                if response: self.speak(response, lang=lang)
            except KeyboardInterrupt: self._running = False
            except Exception as e: print(f"  ✗ Error: {e}"); time.sleep(1)

if __name__ == "__main__": VoiceInterface().run()
PYEOF

echo "✓ Application updated."

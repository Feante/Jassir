"""
Jassir Voice Interface — Fully Voice-Operated Assistant

Listens continuously for a wake word ("jarvis" / "hey jarvis"),
then enters a conversation mode where you can speak naturally without repeating the wake word.
Completely hands-free — no keyboard interaction needed.
"""

import speech_recognition as sr
import pyttsx3
import sys
import os
import threading
import time
import re
import ctypes
import subprocess
import tempfile
from typing import Optional

from jassir_core import jassir


def _suppress_alsa_errors():
    """Suppress noisy ALSA error messages on Linux."""
    try:
        asound = ctypes.cdll.LoadLibrary('libasound.so.2')
        ERROR_HANDLER = ctypes.CFUNCTYPE(None, ctypes.c_char_p, ctypes.c_int,
                                         ctypes.c_char_p, ctypes.c_int,
                                         ctypes.c_char_p)
        def _null_handler(filename, line, function, err, fmt):
            pass
        asound.snd_lib_error_set_handler(ERROR_HANDLER(_null_handler))
    except Exception:
        pass

_suppress_alsa_errors()


class VoiceInterface:
    """Hands-free, wake-word activated voice assistant with Conversation Mode."""

    WAKE_WORDS = ["jarvis", "hey jarvis", "yo jarvis", "ok jarvis", "jassir", "hey jassir"]
    EXIT_PHRASES = ["exit", "quit", "goodbye", "stop", "shut down", "go to sleep", "terminate"]
    
    PIPER_EXE = os.path.expanduser("~/.jassir/bin/piper-tts")
    PIPER_MODEL = os.path.expanduser("~/.jassir/models/tts/en_US-lessac-medium.onnx")

    CONVERSATION_TIMEOUT = 10  # Seconds to stay active without wake word

    def __init__(self):
        # --- Speech Recognition ---
        self.recognizer = sr.Recognizer()
        self.recognizer.energy_threshold = 300
        self.recognizer.dynamic_energy_threshold = True
        self.recognizer.pause_threshold = 5.0  # Wait 5 seconds before ending capture

        # --- Text-to-Speech (Fallback) ---
        try:
            self.tts_engine = pyttsx3.init()
            self.tts_engine.setProperty('rate', 170)
            voices = self.tts_engine.getProperty('voices')
            for v in voices:
                if 'english' in v.name.lower():
                    self.tts_engine.setProperty('voice', v.id)
                    break
        except Exception:
            self.tts_engine = None

        # --- State ---
        self._running = False
        self._tts_lock = threading.Lock()
        self._conversation_mode = False
        self._last_interaction_time = 0

    # ── TTS helpers ──────────────────────────────────────────

    def speak(self, text: str):
        """Thread-safe neural TTS output using Piper with temporary file."""
        if not text.strip():
            return

        with self._tts_lock:
            print(f"\n  Jarvis: {text}")
            
            # Clean text of markdown-style symbols
            clean_text = text.replace("*", "").replace("_", "").strip()
            
            # Try Piper first
            if os.path.exists(self.PIPER_EXE) and os.path.exists(self.PIPER_MODEL):
                try:
                    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_wav:
                        temp_path = temp_wav.name

                    piper_cmd = [self.PIPER_EXE, "--model", self.PIPER_MODEL, "--output_file", temp_path]
                    
                    process = subprocess.Popen(piper_cmd, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    process.communicate(input=clean_text.encode('utf-8'))
                    
                    if process.returncode == 0 and os.path.exists(temp_path) and os.path.getsize(temp_path) > 0:
                        subprocess.run(["aplay", "-q", temp_path], check=True)
                        
                    if os.path.exists(temp_path):
                        os.remove(temp_path)
                    
                    # Reset the conversation timer AFTER speaking finishes
                    self._last_interaction_time = time.time()
                    return
                except Exception as e:
                    print(f"  ⚠ Piper error: {e}")
            
            # Fallback
            if self.tts_engine:
                self.tts_engine.say(clean_text)
                self.tts_engine.runAndWait()
                self._last_interaction_time = time.time()

    def _beep_ready(self):
        """Quick signal that Jarvis is listening."""
        # Use a faster, shorter response for conversation mode
        if self._conversation_mode:
            print("\n  [Listening...]")
        else:
            self.speak("Yes?")

    # ── Speech Recognition helpers ───────────────────────────

    def _recognize(self, audio) -> Optional[str]:
        try:
            return self.recognizer.recognize_google(audio)
        except sr.UnknownValueError:
            return None
        except sr.RequestError as e:
            print(f"  ⚠ Speech API error: {e}")
            return None

    def _contains_wake_word(self, text: str) -> bool:
        t = text.lower().strip()
        return any(ww in t for ww in self.WAKE_WORDS)

    def _strip_wake_word(self, text: str) -> str:
        t = text.strip()
        lower = t.lower()
        for ww in sorted(self.WAKE_WORDS, key=len, reverse=True):
            if lower.startswith(ww):
                t = t[len(ww):].lstrip(" ,.")
                break
        return t.strip()

    def _is_exit_phrase(self, text: str) -> bool:
        t = text.lower().strip()
        return any(ep in t for ep in self.EXIT_PHRASES)

    # ── Core listening ───────────────────────────────────────

    def _listen_for_wake_word(self, source) -> Optional[str]:
        try:
            print("  [Standby - Waiting for 'Jarvis'...]", end="\r")
            audio = self.recognizer.listen(source, timeout=None, phrase_time_limit=5)
            text = self._recognize(audio)
            
            if text:
                if self._contains_wake_word(text):
                    print(f"  ✓ Wake word detected!")
                    return text
            return None
                
        except Exception:
            return None

    def _listen_for_command(self, source) -> Optional[str]:
        try:
            # Short timeout for conversation mode to keep it snappy
            timeout = 5 if self._conversation_mode else 8
            audio = self.recognizer.listen(source, timeout=timeout, phrase_time_limit=20)
            text = self._recognize(audio)
            if text:
                print(f"  🗣️  You: {text}")
                return text
        except sr.WaitTimeoutError:
            if self._conversation_mode:
                print("  ⏳ Conversation timed out. Going back to standby.")
        except Exception as e:
            print(f"  ⚠ Command capture error: {e}")
        return None

    # ── Main loop ────────────────────────────────────────────

    def run(self):
        self._running = True

        print()
        print("=" * 58)
        print("  🎙️  JASSIR — Hands-Free Voice Assistant")
        print("=" * 58)
        print()
        print("  1. Say 'Jarvis' to start a conversation.")
        print("  2. Once Jarvis answers, you don't need to say the name again.")
        print(f"  3. He will stay active for {self.CONVERSATION_TIMEOUT}s of silence.")
        print()

        if not jassir.initialized:
            print("  ⏳ Initializing LLM…")
            if not jassir.initialize_llm():
                print("  ✗ Failed to initialize LLM. Exiting.")
                sys.exit(1)

        self.speak("Jarvis is online and ready.")

        try:
            with sr.Microphone() as source:
                print("  🔇 Calibrating microphone…")
                self.recognizer.adjust_for_ambient_noise(source, duration=1.5)
                print("  ✓ Calibration complete.\n")

                while self._running:
                    # Check if we are in conversation mode
                    now = time.time()
                    if self._conversation_mode and (now - self._last_interaction_time) > self.CONVERSATION_TIMEOUT:
                        self._conversation_mode = False
                        print("  [Switching to Standby Mode]")

                    if not self._conversation_mode:
                        # STANDBY MODE: Listening for wake word
                        wake_text = self._listen_for_wake_word(source)
                        if wake_text is None:
                            continue
                        
                        self._conversation_mode = True
                        command = self._strip_wake_word(wake_text)
                        
                        # If no command followed the wake word, ask "Yes?"
                        if not command:
                            self._beep_ready()
                            command = self._listen_for_command(source)
                    else:
                        # CONVERSATION MODE: Listening directly for commands
                        command = self._listen_for_command(source)
                        if not command:
                            # Re-check timeout in next loop
                            continue

                    if not command:
                        continue

                    if self._is_exit_phrase(command):
                        self.speak("Goodbye.")
                        self._running = False
                        break

                    print(f'\n  💭 Processing...')
                    try:
                        response = jassir.query(command)
                    except Exception as e:
                        response = f"Sorry, I hit an error: {e}"

                    self.speak(response)
                    # _last_interaction_time is updated inside speak()

        except KeyboardInterrupt:
            print("\n\n  ⏹  Stopped.")
        except OSError as e:
            print(f"\n  ✗ Microphone error: {e}")
        finally:
            self._running = False


if __name__ == "__main__":
    vi = VoiceInterface()
    vi.run()

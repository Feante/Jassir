#!/bin/bash
VENV_PATH="$HOME/.jassir/venv"
python -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"
pip install --upgrade pip
pip install --no-cache-dir \
    llama-cpp-python \
    obsidian-sdk \
    psutil \
    torch \
    streamlit \
    pydub \
    speechrecognition \
    pyttsx3 \
    langchain \
    langchain-community \
    sentence-transformers \
    fastapi \
    uvicorn \
    websockets \
    aiohttp \
    aiofiles \
    python-multipart \
    pyaudio

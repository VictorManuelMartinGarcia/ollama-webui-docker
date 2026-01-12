#!/bin/bash
set -e

echo '[Ollama Init] Starting Ollama server...'

ollama serve > /tmp/ollama-server.log 2>&1 &
SERVER_PID=$!

echo '[Ollama Init] Waiting for server...'
for i in {1..60}; do
  if ollama list >/dev/null 2>&1; then
    echo '[Ollama Init] Ollama ready'
    break
  fi
  sleep 1
done

download_model() {
  local model="$1"

  if ollama list | grep -q "^$model"; then
    echo "[Ollama Init] ✔ $model already present"
    return
  fi

  echo "[Ollama Init] ⬇ Downloading $model..."
  ollama pull "$model" >/dev/null
  echo "[Ollama Init] ✅ $model downloaded"
}

download_model llama3
download_model mistral
download_model phi3

echo '[Ollama Init] All models ready'
ollama list

wait $SERVER_PID

#!/bin/bash

echo '[Ollama Init] Starting Ollama server...'

ollama serve > /tmp/ollama-server.log 2>&1 &
SERVER_PID=$!

echo '[Ollama Init] Waiting for server to become available...'
for i in {1..60}; do
  if ollama list > /dev/null 2>&1; then
    echo '[Ollama Init] Ollama server ready'
    break
  fi
  sleep 1
done

echo '[Ollama Init] Starting model download...'
echo '[Ollama Init] Downloading llama3...'
ollama pull llama3 2>&1 | while IFS= read -r line; do echo '[llama3] $line'; done

echo '[Ollama Init] Downloading mistral...'
ollama pull mistral 2>&1 | while IFS= read -r line; do echo '[mistral] $line'; done

echo '[Ollama Init] Downloading phi3...'
ollama pull phi3 2>&1 | while IFS= read -r line; do echo '[phi3] $line'; done

echo '[Ollama Init] All models downloaded. Ollama server running.'
echo '[Ollama Init] Available models:'
ollama list

wait $SERVER_PID

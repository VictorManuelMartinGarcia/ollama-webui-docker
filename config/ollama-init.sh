#!/bin/bash

echo "[Ollama Init] Iniciando servidor Ollama..."

# Arrancar ollama serve en background
ollama serve > /tmp/ollama-server.log 2>&1 &
SERVER_PID=$!

# Esperar a que el servidor esté listo (máximo 60 segundos)
echo "[Ollama Init] Esperando a que el servidor esté disponible..."
for i in {1..60}; do
  if ollama list > /dev/null 2>&1; then
    echo "[Ollama Init] Servidor Ollama listo"
    break
  fi
  sleep 1
done

# Descargar modelos
echo "[Ollama Init] Iniciando descarga de modelos..."
echo "[Ollama Init] Descargando llama3..."
ollama pull llama3 2>&1 | while IFS= read -r line; do echo "[llama3] $line"; done

echo "[Ollama Init] Descargando mistral..."
ollama pull mistral 2>&1 | while IFS= read -r line; do echo "[mistral] $line"; done

echo "[Ollama Init] Descargando phi3..."
ollama pull phi3 2>&1 | while IFS= read -r line; do echo "[phi3] $line"; done

echo "[Ollama Init] Todos los modelos descargados. Servidor Ollama en marcha."
echo "[Ollama Init] Modelos disponibles:"
ollama list

# Esperar a que termine el servidor (traerlo al foreground)
wait $SERVER_PID

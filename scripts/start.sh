#!/bin/bash
set -e

# =========================
# Load .env if exists
# =========================
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi

echo "=== Detecting hardware ==="

GPU_SECTION=""

if command -v nvidia-smi &>/dev/null; then
  echo "✅ GPU NVIDIA detected"
  GPU_SECTION="
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities:
                - gpu"
elif command -v rocminfo &>/dev/null; then
  echo "✅ GPU AMD ROCm detected"
  GPU_SECTION="
    deploy:
      resources:
        reservations:
          devices:
            - driver: amd
              count: 1
              capabilities:
                - gpu"
else
  echo "⚠️  No compatible GPU detected. Using CPU."
fi

echo "=== Generating docker-compose.generated.yml ==="

# =========================
# Base compose
# =========================
cat > compose/docker-compose.generated.yml <<EOF
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "\${OLLAMA_PORT:-11434}:11434"
    volumes:
      - ../data/ollama_data:/root/.ollama
      - ../config/ollama-init.sh:/app/ollama-init.sh:ro
    restart: unless-stopped
    entrypoint: ["/bin/bash", "/app/ollama-init.sh"]
    networks:
      - llm_webui_network
$GPU_SECTION

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "\${WEBUI_PORT:-8080}:8080"
    volumes:
      - ../data/openwebui_data:/app/backend/data
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    depends_on:
      - ollama
    restart: unless-stopped
    networks:
      - llm_webui_network
EOF

# =========================
# Telegram bot
# =========================
if [ -n "$TELEGRAM_TOKEN" ]; then
  cat >> compose/docker-compose.generated.yml <<EOF

  telegram-bot:
    build: ../telegram-bot
    container_name: telegram-bot
    environment:
      - TELEGRAM_TOKEN=$TELEGRAM_TOKEN
      - OLLAMA_BASE_URL=http://ollama:11434
      - OLLAMA_MODEL=${TELEGRAM_BOT_MODEL:-phi3:latest}
    depends_on:
      - ollama
    restart: unless-stopped
    networks:
      - llm_webui_network
EOF
  echo "✅ Telegram bot added to generated compose"
else
  echo "⚠️ TELEGRAM_TOKEN not defined. Telegram bot will NOT be added."
fi

# =========================
# Networks
# =========================
cat >> compose/docker-compose.generated.yml <<EOF

networks:
  llm_webui_network:
    driver: bridge
EOF

echo "✅ Generated file: docker-compose.generated.yml"

# =========================
# Start containers
# =========================
docker compose -f compose/docker-compose.generated.yml up -d

# =========================
# Wait for models
# =========================
START_TIME=$(date +%s)
TIMEOUT=1800   # 30 minutos

# REQUIRED_MODELS=($OLLAMA_MODELS)
read -r -a REQUIRED_MODELS <<< "$OLLAMA_MODELS"

echo "=== Waiting for Ollama & model (${REQUIRED_MODELS[@]}) downloads ==="
echo "💤 This may take several minutes on first run..."

for model in "${REQUIRED_MODELS[@]}"; do
  # Comprobar si ya está descargado
  if docker exec ollama ollama list | grep -q "^$model"; then
    echo "✅ $model already downloaded"
    continue
  fi

  echo "⏳ $model downloading..."
  
  START_TIME=$(date +%s)
  TIMEOUT=1800   # 30 minutos

  docker exec ollama ollama pull "$model" >/dev/null 2>&1

  while true; do
    sleep 2
    if docker exec ollama ollama list | grep -q "^$model"; then
      echo "✅ $model downloaded"
      break
    fi

    NOW=$(date +%s)
    if (( NOW - START_TIME > TIMEOUT )); then
      echo "❌ Timeout waiting for $model"
      exit 1
    fi
  done
done

echo "✅ All models downloaded successfully"

echo ""
echo "🚀 All set!"
echo "🌐 Open WebUI: http://localhost:8080"
echo "🤖 Telegram bot is ready (if enabled)"

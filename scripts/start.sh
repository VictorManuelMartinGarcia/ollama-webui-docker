#!/bin/bash

echo "=== Detecting  hardware ==="

GPU_SECTION=""

# NVIDIA
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
                - gpu
  "

# AMD ROCm
elif command -v rocminfo &>/dev/null; then
  echo "✅ GPU AMD ROCm detected"
  export HSA_OVERRIDE_GFX_VERSION=10.3.0
  GPU_SECTION="
    deploy:
      resources:
        reservations:
          devices:
            - driver: amd
              count: 1
              capabilities:
                - gpu
  "

# CPU
else
  echo "⚠️ No compatible GPU detected. Using CPU."
  GPU_SECTION=""
fi

echo "=== Generating docker-compose.generated.yml ==="

if [[ -n "$GPU_SECTION" ]]; then
  awk -v gpu="$GPU_SECTION" '
      /container_name: ollama/ {print; getline; print; print gpu; next}
      {print}
    ' compose/docker-compose.template.yml > compose/docker-compose.generated.yml
else
  awk '
    BEGIN {skip=0}
    /deploy:/ {skip=1}
    skip && /capabilities:/ {skip=0; next}
    skip {next}
    {print}
  ' compose/docker-compose.template.yml > compose/docker-compose.generated.yml
fi

echo "✅ Generated file: docker-compose.generated.yml"
echo '=== Starting containers ==='

docker compose -f compose/docker-compose.generated.yml up -d

echo '=== Waiting for models to download and Ollama to be ready... ==='
echo 'Showing logs in real time:'
echo ""

timeout 600 docker logs -f ollama 2>&1 | grep -v '\[GIN\]' &
LOGS_PID=$!

# Esperar a que los 3 modelos estén descargados
start_time=$(date +%s)
timeout_seconds=600

while true; do
  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  
  if [ $elapsed -gt $timeout_seconds ]; then
    echo "Timeout waiting for models"
    break
  fi
  
  models_ready=$(docker exec ollama ollama list 2>/dev/null | grep -cE 'llama3|mistral|phi3')
  
  if [ "$models_ready" -eq 3 ]; then
    sleep 1
    break
  fi
  
  sleep 3
done

kill -5 $LOGS_PID 2>/dev/null
wait $LOGS_PID 2>/dev/null

echo ""
echo '✅ All set. Ollama + OpenWebUI are up and running, and the models have been downloaded.'
echo '🌐 Open in your browser: http://localhost:8080'
echo '📝 You can now select the models (llama3, mistral, phi3) and have conversations.'

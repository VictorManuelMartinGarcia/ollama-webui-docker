#!/bin/bash

echo "=== Detectando hardware ==="

GPU_SECTION=""

# NVIDIA
if command -v nvidia-smi &>/dev/null; then
  echo "✅ GPU NVIDIA detectada"
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
  echo "✅ GPU AMD ROCm detectada"
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
  echo "⚠️ No se detectó GPU compatible. Usando CPU."
  GPU_SECTION=""
fi

echo "=== Generando docker-compose.generated.yml ==="

# Insertar GPU_SECTION solo si no está vacío
if [[ -n "$GPU_SECTION" ]]; then
  awk -v gpu="$GPU_SECTION" '
      /container_name: ollama/ {print; getline; print; print gpu; next}
      {print}
    ' compose/docker-compose.template.yml > compose/docker-compose.generated.yml
else
  # Si no hay GPU, eliminar cualquier bloque deploy/resources/reservations/devices del template
  awk '
    BEGIN {skip=0}
    /deploy:/ {skip=1}
    skip && /capabilities:/ {skip=0; next}
    skip {next}
    {print}
  ' compose/docker-compose.template.yml > compose/docker-compose.generated.yml
fi

echo "✅ Archivo generado: docker-compose.generated.yml"
echo "=== Iniciando contenedores ==="

docker compose -f compose/docker-compose.generated.yml up -d

echo "=== Esperando a que se descarguen los modelos y Ollama esté listo... ==="
echo "Mostrando logs en tiempo real:"
echo ""

# Mostrar logs en tiempo real (filtrando los logs de peticiones HTTP [GIN])
timeout 600 docker logs -f ollama 2>&1 | grep -v '\[GIN\]' &
LOGS_PID=$!

# Esperar a que los 3 modelos estén descargados
start_time=$(date +%s)
timeout_seconds=600

while true; do
  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  
  if [ $elapsed -gt $timeout_seconds ]; then
    echo "Timeout esperando modelos"
    break
  fi
  
  models_ready=$(docker exec ollama ollama list 2>/dev/null | grep -cE 'llama3|mistral|phi3')
  
  if [ "$models_ready" -eq 3 ]; then
    sleep 1
    break
  fi
  
  sleep 3
done

# Parar los logs forzadamente
kill -5 $LOGS_PID 2>/dev/null
wait $LOGS_PID 2>/dev/null

echo ""
echo "✅ Todo listo. Ollama + OpenWebUI están en marcha y los modelos están descargados."
echo "🌐 Abre en tu navegador: http://localhost:8080"
echo "📝 Ya puedes seleccionar los modelos (llama3, mistral, phi3) y tener conversaciones."

#!/bin/bash

echo "=== Limpiando ollama_webui ==="
echo ""
echo "⚠️  Esto eliminará:"
echo "  - Contenedores Docker (Ollama y Open WebUI)"
echo "  - Modelos descargados (ollama_data/)"
echo "  - Datos de Open WebUI (openwebui_data/)"
echo "  - Archivo docker-compose.generated.yml"
echo ""
read -p "¿Estás seguro? (s/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
  echo "Operación cancelada."
  exit 1
fi

echo ""
echo "Parando y eliminando contenedores..."
docker compose -f compose/docker-compose.generated.yml down 2>/dev/null || true

echo "Eliminando modelos descargados..."
sudo rm -rf data/ollama_data 2>/dev/null || rm -rf data/ollama_data

echo "Eliminando datos de Open WebUI..."
sudo rm -rf data/openwebui_data 2>/dev/null || rm -rf data/openwebui_data

echo "Eliminando archivo docker-compose.generated.yml..."
rm -f compose/docker-compose.generated.yml
echo ""

echo "✅ Todo limpio. Proyecto restaurado al estado inicial."
echo "Ejecuta ./start.sh para volver a comenzar."

#!/bin/bash

echo '=== Cleaning ollama_webui ==='
echo ''
echo '⚠️  This will delete:'
echo '  - Docker containers (Ollama and Open WebUI)'
echo '  - Downloaded models (ollama_data/)'
echo '  - Open WebUI data (openwebui_data/)'
echo '  - docker-compose.generated.yml file'
echo ''
read -p 'Are you sure? (y/n): ' -n 1 -r
echo ''

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo 'Operation cancelled.'
  exit 1
fi

echo ''
echo 'Stopping and deleting containers...'
docker compose -f compose/docker-compose.generated.yml down 2>/dev/null || true

echo 'Deleting downloaded models...'
sudo rm -rf data/ollama_data 2>/dev/null || rm -rf data/ollama_data

echo 'Deleting Open WebUI data...'
sudo rm -rf data/openwebui_data 2>/dev/null || rm -rf data/openwebui_data

echo 'Deleting docker-compose.generated.yml file...'
rm -f compose/docker-compose.generated.yml
echo ''

echo '✅ All clean. Project restored to initial state.'
echo 'Run ./start.sh to start again.'

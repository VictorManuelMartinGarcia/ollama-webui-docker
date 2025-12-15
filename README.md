
# Ollama WebUI Docker

Un sistema de chat local con modelos de lenguaje (LLM) completamente dockerizado, usando **Ollama** y **Open WebUI**. Detección automática de hardware, descarga automática de modelos y gestión sencilla con scripts bash.

> **Completamente local** • Sin dependencias en la nube • Privacidad garantizada

---

## ✨ Características

- ✅ **Detección automática de hardware** - Detecta NVIDIA GPU, AMD ROCm o CPU automáticamente
- ✅ **Descarga automática de modelos** - Llama3, Mistral, Phi3 descargan solos al inicio
- ✅ **Interfaz moderna** - Open WebUI con chat, historial y configuración
- ✅ **Persistencia de datos** - Los modelos e historial se mantienen entre reinicios
- ✅ **Scripts de utilidad** - `start.sh` y `clean.sh` para gestionar fácilmente
- ✅ **Completamente privado** - Todo corre localmente, sin conexiones externas
- ✅ **Fácil de migrar** - Copia la carpeta a otra máquina y funciona al instante

---

## 🛠️ Requisitos

| Recurso | Mínimo | Recomendado |
|---------|--------|-------------|
| **Espacio disco** | 25 GB | 50 GB+ |
| **RAM** | 8 GB | 16 GB+ |
| **GPU** | - | NVIDIA o AMD |
| **Software** | Docker + Docker Compose | Última versión |

**Instalar Docker:** [Instrucciones oficiales](https://docs.docker.com/get-docker/)

---

## 🚀 Inicio Rápido

### Configuración inicial (opcional)

Si quieres cambiar puertos o configuración:

```bash
cp .env.example .env
# Edita .env con tus valores personalizados
nano .env
```

**Variables disponibles en `.env`:**
```env
# Puertos (por defecto 8080 para Open WebUI, 11434 para Ollama)
OLLAMA_PORT=11434
WEBUI_PORT=8080

# Configuración de Ollama
OLLAMA_KEEP_ALIVE=5m          # Mantener modelo en memoria
OLLAMA_NUM_PARALLEL=1         # Peticiones paralelas
```

### Primer arranque (descargará modelos automáticamente)

```bash
git clone https://github.com/tu-usuario/ollama_webui.git
cd ollama_webui
chmod +x scripts/start.sh scripts/clean.sh
scripts/start.sh
```

El script hará todo automáticamente:
1. 🔍 Detectar tu hardware (GPU o CPU)
2. 🔧 Generar `docker-compose.generated.yml` optimizado
3. 🐳 Arrancar Ollama y Open WebUI (en los puertos configurados en `.env`)
4. 📥 Descargar modelos (llama3, mistral, phi3)
5. ✅ Mostrar mensaje cuando esté listo

**Tiempo estimado:** 20-60 minutos (primera vez, depende de tu conexión)

### Cuando veas "Todo listo ✅"

Abre en tu navegador (usa el puerto que configuraste en `.env`):
```
http://localhost:{WEBUI_PORT}
```

Selecciona un modelo y empieza a chatear. ¡Así de simple!

---

## 📂 Estructura del Proyecto

```
ollama_webui/
├── scripts/                          # Scripts principales
│   ├──🚀 start.sh                    # Arranca todo (hardware detection + modelos)
│   └──🧹 clean.sh                    # Limpia contenedores + modelos + datos
│
├── config/                           # ⚙️ Configuración de servicios
│   └──🔧 ollama-init.sh              # Inicialización de Ollama (descarga modelos)
│
├── compose/                          # 🐳 Docker Compose
│   ├── docker-compose.template.yml   # Plantilla base (usa variables de .env)
│   └── docker-compose.generated.yml  # Se crea automáticamente (no subir a Git)
│
├── 📁 data/                         # 💾 Datos persistentes (ignorar en Git)
│   ├── ollama_data/                  # Modelos descargados
│   └── openwebui_data/               # 💬 Historial de chat y configuración
│
├── 📖 README.md                      # Este archivo
├── ⚖️  LICENSE                        # MIT License
├── 📁 .gitignore                     # Archivos ignorados en Git
├── ⚙️  .env.example                   # Ejemplo de configuración (subir a Git)
└── 📄 .env                           # Tu configuración local (ignorar en Git)
```

---

## 📚 Uso

### Comandos principales

```bash
# Primera vez - descarga modelos y arranca todo
./start.sh

# Parar contenedores (mantiene datos)
docker compose -f compose/docker-compose.generated.yml stop

# Reiniciar (rápido, sin descargar modelos)
docker compose -f compose/docker-compose.generated.yml start

# Limpiar todo (borra contenedores, modelos, datos)
./clean.sh
```

### Ver estado

```bash
# Estado de contenedores
docker compose -f compose/docker-compose.generated.yml ps

# Logs de Ollama
docker logs -f ollama

# Logs de Open WebUI
docker logs -f open-webui

# Listar modelos descargados
docker exec -it ollama ollama list
```

---

## ⚙️ Configuración

### Cambiar puertos

1. Copia el archivo de ejemplo:
   ```bash
   cp .env.example .env
   ```

2. Edita `.env` y cambia los puertos según necesites:
   ```env
   OLLAMA_PORT=11434      # Cambiar puerto de Ollama si es necesario
   WEBUI_PORT=9000        # Cambiar puerto de Open WebUI (ej: 9000)
   ```

3. Ejecuta `./start.sh` para aplicar cambios:
   ```bash
   scripts/start.sh
   ```

4. Abre `http://localhost:9000` (o el puerto que configuraste)

### Optimizar Ollama

En `.env` puedes ajustar el comportamiento de Ollama:

```env
# Tiempo que Ollama mantiene el modelo cargado en memoria
OLLAMA_KEEP_ALIVE=5m     # Aumenta si quieres respuestas más rápidas
                         # Disminuye si quieres liberar memoria

# Cuántas peticiones procesa Ollama simultáneamente  
OLLAMA_NUM_PARALLEL=1    # Aumenta si tienes mucha RAM/GPU
```

---

## 🔧 Personalización

### Cambiar modelos a descargar

Edita `ollama-init.sh` y modifica estas líneas:

```bash
echo "[Ollama Init] Descargando modelos..."
echo "[Ollama Init] Descargando llama3..."
ollama pull llama3 2>&1 | while IFS= read -r line; do echo "[llama3] $line"; done

echo "[Ollama Init] Descargando mistral..."
ollama pull mistral 2>&1 | while IFS= read -r line; do echo "[mistral] $line"; done

echo "[Ollama Init] Descargando phi3..."
ollama pull phi3 2>&1 | while IFS= read -r line; do echo "[phi3] $line"; done
```

**Otros modelos disponibles en [ollama.com](https://ollama.com/library):**
- `neural-chat` - Chat optimizado
- `dolphin-mixtral` - Modelo potente
- `openchat` - Alternativa a Mistral
- `starling-lm` - Buen balance
- Y muchos más...

Después de cambiar, ejecuta `./start.sh` para descargar los nuevos modelos.

### Configurar GPU manualmente

Si `start.sh` no detecta tu GPU correctamente:

1. Edita `docker-compose.template.yml` y busca la sección `deploy` en el servicio `ollama`

2. **Para NVIDIA:**
   ```yaml
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: 1
             capabilities: [gpu]
   ```

3. **Para AMD ROCm:**
   ```yaml
   deploy:
     resources:
       reservations:
         devices:
           - driver: amd
             count: 1
             capabilities: [gpu]
   ```

4. Luego ejecuta:
   ```bash
   docker compose -f compose/docker-compose.generated.yml down
   ./start.sh
   ```

---

## 🎯 Scripts disponibles

| Script | Función | Tiempo |
|--------|---------|--------|
| `./start.sh` | Detecta hardware, genera Compose, arranca todo y descarga modelos | 20-60 min (1ª vez) |
| `./clean.sh` | Elimina contenedores, modelos y datos. Restaura estado inicial | 1-2 min |

---

## ⚡ Rendimiento

### Velocidad por hardware

| Hardware | Velocidad aproximada |
|----------|---------------------|
| **CPU moderno** | 1-5 segundos/respuesta |
| **GPU NVIDIA** | 100-500ms/respuesta |
| **GPU AMD** | 100-500ms/respuesta |

### Optimizaciones

- **Aumentar RAM dedicada:** Edita Docker Desktop settings
- **Cerrar otras aplicaciones:** Libera memoria
- **Usar modelos más pequeños:** Phi3 es más rápido que Llama3

---

## ⚠️ Consideraciones importantes

### Espacio en disco

Cada modelo ocupa:
- **llama3** → 4.7 GB
- **mistral** → 4.4 GB
- **phi3** → 2.2 GB
- **Total por defecto** → 11 GB

**Mantén mínimo 25 GB libres** para no saturar el disco.

### Persistencia de datos

- `ollama_data/` → Modelos descargados
- `openwebui_data/` → Historial de chat y configuración
- **Ambas se ignoran en Git** (ver `.gitignore`)
- **No las borres** si quieres mantener tus datos

### Migración a otra máquina

```bash
# Copia todo incluyendo datos
cp -r ollama_webui /ruta/destino/

# En la máquina nueva
cd ollama_webui
./start.sh  # Continuará con modelos ya descargados
```

### Primera ejecución

- La descarga de modelos **toma bastante tiempo** (20-60 min)
- El script mostrará progreso en tiempo real
- **No cierres el script** hasta que veas "Todo listo ✅"
- Puedes dejar corriendo mientras haces otras cosas

---

## 🐛 Troubleshooting

### "docker: command not found"
→ Instala Docker desde https://docs.docker.com/get-docker/

### El script se queda esperando
→ Normal la primera vez. Déjalo correr. Ver logs con `docker logs -f ollama`

### Open WebUI no muestra modelos
→ Espera a que termine la descarga. Ver `docker exec -it ollama ollama list`

### Poco espacio en disco
→ Ejecuta `./clean.sh` para limpiar y empezar de nuevo

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios importantes:

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/mejora`)
3. Commit cambios (`git commit -m 'Añade mejora'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abre un Pull Request

---

## 📝 Licencia

Este proyecto está bajo licencia **MIT**. Ver [LICENSE](LICENSE) para detalles completos.

---

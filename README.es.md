# SIM AI STUDIO - Guía de Instalación y Configuración

<p align="center">
  <img src="apps/sim/public/logo/reverse/text/large.png" alt="Sim Logo" width="500"/>
</p>

<p align="center">Construye y despliega flujos de trabajo de agentes de IA en minutos.</p>

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación Rápida](#-instalación-rápida)
- [Configuración Detallada](#-configuración-detallada)
- [Despliegue en Producción](#-despliegue-en-producción)
- [Comandos Útiles](#-comandos-útiles)
- [Solución de Problemas](#-solución-de-problemas)
- [Seguridad](#-seguridad)
- [Stack Tecnológico](#-stack-tecnológico)

## 🎯 Descripción General

**SIM AI Studio v0.5.60** es una plataforma visual para construir y desplegar flujos de trabajo con agentes de IA. Esta guía te ayudará a configurar el proyecto con Docker siguiendo las mejores prácticas de nivel senior.

### Características Principales

- ✅ **Despliegue con Docker** - Configuración idempotente y reproducible
- ✅ **Base de datos PostgreSQL** con extensión pgvector
- ✅ **Servidor en tiempo real** con Socket.IO
- ✅ **Seguridad de producción** - Secretos robustos y aislamiento de red
- ✅ **Health checks** automatizados
- ✅ **Límites de recursos** configurables
- ✅ **Logs estructurados** con rotación automática

## 📦 Requisitos Previos

### Software Requerido

- **Docker** >= 24.0.0 ([Instalar Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** >= 2.20.0 (incluido con Docker Desktop)
- **Git** >= 2.40.0

### Recursos del Sistema

**Mínimo:**
- CPU: 2 núcleos
- RAM: 8 GB
- Disco: 20 GB disponibles

**Recomendado:**
- CPU: 4+ núcleos
- RAM: 16+ GB
- Disco: 50+ GB disponibles (especialmente si usas Ollama)

### Verificar Instalación

```bash
# Verificar Docker
docker --version
docker info

# Verificar Docker Compose
docker compose version
```

## 🚀 Instalación Rápida

### 1. Clonar el Repositorio

```bash
# Clonar usando el tag recomendado (v0.5.60)
git clone https://github.com/simstudioai/sim.git
cd sim
git checkout tags/v0.5.60 -b simstudio-0.5.60
```

### 2. Generar Secretos de Seguridad

```bash
# Ejecutar el generador de secretos
./scripts/generate-secrets.sh

# Este comando generará secretos criptográficamente seguros
# Copia la salida a tu archivo .env
```

### 3. Configurar Variables de Entorno

```bash
# Copiar el archivo de ejemplo
cp .env.example .env

# Editar con tu editor favorito
nano .env  # o vim, code, etc.
```

**Variables REQUERIDAS mínimas:**

```env
# Seguridad (reemplazar con los valores generados)
BETTER_AUTH_SECRET=tu_secreto_de_32_caracteres_hex
ENCRYPTION_KEY=tu_clave_de_encriptacion_32_caracteres
INTERNAL_API_SECRET=tu_secreto_api_interno_32_caracteres
API_ENCRYPTION_KEY=tu_clave_encriptacion_api_32_caracteres

# Base de datos
POSTGRES_USER=postgres
POSTGRES_PASSWORD=cambiar_en_produccion
POSTGRES_DB=simstudio

# URLs de la aplicación
NEXT_PUBLIC_APP_URL=http://localhost:3000
BETTER_AUTH_URL=http://localhost:3000
```

### 4. Iniciar los Servicios

```bash
# Iniciar todos los servicios
docker compose up -d

# Ver los logs
docker compose logs -f

# Verificar el estado de salud
./scripts/health-check.sh
```

### 5. Acceder a la Aplicación

Abre tu navegador en: **http://localhost:3000**

¡Listo! 🎉

## ⚙️ Configuración Detallada

### Estructura de Archivos

```
sim/
├── .env                      # Variables de entorno (NO commitear)
├── .env.example              # Plantilla de variables
├── docker-compose.yml        # Configuración principal
├── docker-compose.prod.yml   # Configuración original (referencia)
├── docker-compose.ollama.yml # Con modelos locales Ollama
├── scripts/
│   ├── generate-secrets.sh   # Generar secretos seguros
│   ├── health-check.sh       # Verificar estado de servicios
│   └── docker-entrypoint.sh  # Script de inicialización
├── docker/
│   ├── app.Dockerfile        # Imagen de la aplicación
│   ├── realtime.Dockerfile   # Imagen del servidor realtime
│   └── db.Dockerfile         # Imagen de migraciones
└── README.es.md              # Esta guía
```

### Configuración de Base de Datos

#### PostgreSQL con pgvector

El proyecto utiliza **PostgreSQL 17** con la extensión **pgvector** para búsquedas vectoriales:

```yaml
# En docker-compose.yml
db:
  image: pgvector/pgvector:pg17
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: tu_password_seguro
    POSTGRES_DB: simstudio
  volumes:
    - postgres_data:/var/lib/postgresql/data
```

#### Backup de Base de Datos

```bash
# Crear backup
docker exec simstudio-db pg_dump -U postgres simstudio > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker exec -i simstudio-db psql -U postgres simstudio < backup_20240116.sql
```

### Configuración de Proveedores de IA

#### OpenAI

```env
OPENAI_API_KEY=sk-...
OPENAI_API_KEY_1=sk-...  # Clave adicional para balanceo
OPENAI_API_KEY_2=sk-...
```

#### Anthropic (Claude)

```env
ANTHROPIC_API_KEY_1=sk-ant-...
ANTHROPIC_API_KEY_2=sk-ant-...
```

#### Google Gemini

```env
GEMINI_API_KEY_1=...
```

#### Modelos Locales con Ollama

Para usar modelos de IA locales sin APIs externas:

```bash
# Opción 1: Usar docker-compose.ollama.yml
docker compose -f docker-compose.ollama.yml --profile setup up -d

# Opción 2: Ollama en host (configurar .env)
OLLAMA_URL=http://host.docker.internal:11434
```

Descargar modelos adicionales:

```bash
docker compose -f docker-compose.ollama.yml exec ollama ollama pull llama3.1:8b
docker compose -f docker-compose.ollama.yml exec ollama ollama pull codellama
docker compose -f docker-compose.ollama.yml exec ollama ollama pull mistral
```

### Configuración de Email

#### Resend (Recomendado)

```env
RESEND_API_KEY=re_...
FROM_EMAIL_ADDRESS=noreply@tudominio.com
EMAIL_DOMAIN=tudominio.com
```

#### Twilio (SMS)

```env
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+1234567890
```

### Configuración de Almacenamiento

#### AWS S3

```env
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
S3_BUCKET_NAME=sim-storage
S3_KB_BUCKET_NAME=sim-knowledge-base
```

#### Azure Blob Storage

```env
AZURE_ACCOUNT_NAME=tustorage
AZURE_ACCOUNT_KEY=...
AZURE_STORAGE_CONTAINER_NAME=sim-files
AZURE_STORAGE_KB_CONTAINER_NAME=sim-kb
```

## 🏭 Despliegue en Producción

### Checklist de Seguridad Senior

- [x] **HTTPS obligatorio** - Usar reverse proxy (Nginx/Caddy/Traefik)
- [x] **Secretos robustos** - Generar con `openssl rand -hex 32`
- [x] **Contraseñas únicas** - Cambiar valores por defecto
- [x] **Red aislada** - Usar redes Docker privadas
- [x] **Backups automáticos** - Base de datos y volúmenes
- [x] **Monitoreo activo** - Logs y métricas
- [x] **Rate limiting** - Configurar límites apropiados
- [x] **Firewall** - Solo puertos necesarios expuestos

### Reverse Proxy con Nginx

**Archivo: `nginx.conf`**

```nginx
upstream simstudio_app {
    server localhost:3000;
}

upstream simstudio_realtime {
    server localhost:3002;
}

server {
    listen 80;
    server_name tudominio.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tudominio.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    client_max_body_size 100M;

    location / {
        proxy_pass http://simstudio_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /socket.io/ {
        proxy_pass http://simstudio_realtime;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Variables de Entorno para Producción

```env
# Modo de producción
NODE_ENV=production

# URLs públicas (con HTTPS)
NEXT_PUBLIC_APP_URL=https://tudominio.com
BETTER_AUTH_URL=https://tudominio.com
NEXT_PUBLIC_SOCKET_URL=https://tudominio.com

# Deshabilitar telemetría
NEXT_TELEMETRY_DISABLED=1
VERCEL_TELEMETRY_DISABLED=1

# Contraseña robusta de base de datos
POSTGRES_PASSWORD=genera_una_password_muy_segura_aqui

# Límites de recursos (ajustar según tu servidor)
# Ver docker-compose.yml para configurar límites de CPU y RAM
```

### Despliegue con Systemd

**Archivo: `/etc/systemd/system/simstudio.service`**

```ini
[Unit]
Description=SIM AI Studio
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/simstudio
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

```bash
# Habilitar e iniciar el servicio
sudo systemctl enable simstudio
sudo systemctl start simstudio
sudo systemctl status simstudio
```

## 🛠️ Comandos Útiles

### Gestión de Servicios

```bash
# Iniciar servicios
docker compose up -d

# Detener servicios
docker compose down

# Reiniciar servicios
docker compose restart

# Ver logs en tiempo real
docker compose logs -f

# Ver logs de un servicio específico
docker compose logs -f simstudio
docker compose logs -f realtime
docker compose logs -f db

# Ver estado de contenedores
docker compose ps

# Verificar salud de servicios
./scripts/health-check.sh
./scripts/health-check.sh app
./scripts/health-check.sh db
```

### Mantenimiento de Base de Datos

```bash
# Acceder a PostgreSQL
docker exec -it simstudio-db psql -U postgres -d simstudio

# Ejecutar migraciones manualmente
docker compose run --rm migrations bun run db:migrate

# Ver tamaño de la base de datos
docker exec simstudio-db psql -U postgres -d simstudio -c "
    SELECT pg_size_pretty(pg_database_size('simstudio'));"

# Vacuum y analyze
docker exec simstudio-db psql -U postgres -d simstudio -c "VACUUM ANALYZE;"
```

### Gestión de Volúmenes

```bash
# Listar volúmenes
docker volume ls

# Inspeccionar volumen de datos
docker volume inspect simstudio-postgres-data

# Backup de volumen
docker run --rm \
  -v simstudio-postgres-data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/postgres-data-$(date +%Y%m%d).tar.gz /data

# Limpiar volúmenes no utilizados
docker volume prune
```

### Actualización de Imágenes

```bash
# Descargar última versión
docker compose pull

# Recrear contenedores con nuevas imágenes
docker compose up -d --force-recreate

# Limpiar imágenes antiguas
docker image prune -a
```

### Monitoreo de Recursos

```bash
# Ver uso de recursos en tiempo real
docker stats

# Ver recursos de un contenedor específico
docker stats simstudio-app

# Ver procesos dentro de un contenedor
docker compose top simstudio
```

## 🐛 Solución de Problemas

### Problema: No se puede conectar a la base de datos

**Síntomas:**
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Soluciones:**

1. Verificar que el contenedor de la base de datos esté corriendo:
```bash
docker compose ps db
docker compose logs db
```

2. Comprobar health check:
```bash
docker inspect simstudio-db | grep -A 10 Health
```

3. Verificar variables de entorno:
```bash
docker compose exec simstudio env | grep DATABASE_URL
```

### Problema: Puerto ya en uso

**Síntomas:**
```
Error: bind: address already in use
```

**Soluciones:**

1. Cambiar puerto en `.env`:
```env
APP_PORT=3001
SOCKET_PORT=3003
POSTGRES_PORT=5433
```

2. Detener servicio conflictivo:
```bash
# Identificar proceso
sudo lsof -i :3000
# o
sudo netstat -tulpn | grep :3000

# Detener el proceso
sudo kill -9 <PID>
```

### Problema: Modelos de Ollama no aparecen

**Síntomas:**
Los modelos locales no se muestran en el dropdown.

**Soluciones:**

1. Si Ollama está en el host:
```env
# En .env
OLLAMA_URL=http://host.docker.internal:11434
```

2. En Linux, añadir a `docker-compose.yml`:
```yaml
simstudio:
  extra_hosts:
    - "host.docker.internal:host-gateway"
```

### Problema: Error de migraciones

**Síntomas:**
```
Migration failed: relation does not exist
```

**Soluciones:**

1. Limpiar base de datos y volver a migrar:
```bash
# CUIDADO: Esto borra todos los datos
docker compose down -v
docker compose up -d
```

2. Ejecutar migraciones manualmente:
```bash
docker compose run --rm migrations bun run db:migrate
```

### Problema: Aplicación lenta o sin respuesta

**Soluciones:**

1. Verificar recursos:
```bash
docker stats
```

2. Aumentar límites en `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      memory: 16G
      cpus: '8'
```

3. Verificar logs para errores:
```bash
docker compose logs --tail=100 simstudio
```

### Problema: Secretos débiles o por defecto

**Síntomas:**
Warning en logs sobre secretos débiles.

**Soluciones:**

```bash
# Generar nuevos secretos
./scripts/generate-secrets.sh

# Actualizar .env con los nuevos valores

# Recrear contenedores
docker compose down
docker compose up -d
```

## 🔒 Seguridad

### Mejores Prácticas

1. **Secretos Robustos**
```bash
# Generar secretos de 32 bytes (64 caracteres hex)
openssl rand -hex 32
```

2. **Permisos de Archivos**
```bash
# Proteger archivo .env
chmod 600 .env

# Scripts ejecutables solo por propietario
chmod 700 scripts/*.sh
```

3. **Aislamiento de Red**
```yaml
# Usar red privada
networks:
  simstudio-network:
    driver: bridge
    internal: true  # Sin acceso a internet
```

4. **No ejecutar como root**
```yaml
# Los Dockerfiles ya incluyen usuario no-privilegiado
user: nextjs
```

5. **Actualizaciones Regulares**
```bash
# Actualizar imágenes base
docker compose pull
docker compose up -d --force-recreate
```

6. **Backups Automáticos**
```bash
# Añadir a crontab
0 2 * * * cd /opt/simstudio && ./scripts/backup-db.sh
```

### Checklist de Seguridad para Producción

- [ ] HTTPS habilitado con certificados válidos
- [ ] Firewall configurado (solo puertos necesarios)
- [ ] Secretos generados con `openssl rand -hex 32`
- [ ] Variables de entorno no hardcodeadas en código
- [ ] Base de datos con contraseña robusta
- [ ] Backups automáticos configurados
- [ ] Logs monitoreados
- [ ] Rate limiting habilitado
- [ ] Actualización automática de seguridad
- [ ] Escaneo de vulnerabilidades regular

## 🔧 Stack Tecnológico

### Backend

- **Runtime**: Bun 1.3.3
- **Framework**: Next.js 16 (App Router)
- **Base de datos**: PostgreSQL 17 + pgvector
- **ORM**: Drizzle ORM
- **Autenticación**: Better Auth
- **Real-time**: Socket.IO

### Frontend

- **Framework**: React 19
- **Styling**: Tailwind CSS
- **Componentes**: Shadcn/ui
- **Estado**: Zustand
- **Editor visual**: ReactFlow

### Infraestructura

- **Containerización**: Docker + Docker Compose
- **Orquestación**: Kubernetes (Helm charts incluidos)
- **Background Jobs**: Trigger.dev
- **Code Execution**: E2B (opcional)

### Dependencias Python

- **Guardrails**: Validación PII
- **Embeddings**: OpenAI, Azure, etc.
- **OCR**: Azure Mistral

## 📚 Recursos Adicionales

### Documentación Oficial

- [Documentación de SIM](https://docs.sim.ai)
- [GitHub Repository](https://github.com/simstudioai/sim)
- [Discord Community](https://discord.gg/Hr4UWYEcTT)

### Tutoriales y Guías

- [Configurar con Ollama](README.md#using-local-models-with-ollama)
- [Despliegue en Kubernetes](helm/sim/README.md)
- [API de Copilot](README.md#copilot-api-keys)

### Soporte

- **Issues**: [GitHub Issues](https://github.com/simstudioai/sim/issues)
- **Discord**: [Servidor de Discord](https://discord.gg/Hr4UWYEcTT)
- **Twitter/X**: [@simdotai](https://x.com/simdotai)

---

## 📝 Notas Finales

### Contribuciones

Las contribuciones son bienvenidas. Por favor, consulta [CONTRIBUTING.md](.github/CONTRIBUTING.md) para más detalles.

### Licencia

Este proyecto está licenciado bajo Apache License 2.0. Ver [LICENSE](LICENSE) para más detalles.

### Créditos

Desarrollado con ❤️ por el equipo de Sim.

---

**¿Necesitas ayuda?** Únete a nuestro [Discord](https://discord.gg/Hr4UWYEcTT) o abre un [issue en GitHub](https://github.com/simstudioai/sim/issues).

**¿Encontraste un bug?** Por favor, reportalo en [GitHub Issues](https://github.com/simstudioai/sim/issues/new).

**¿Quieres contribuir?** Lee nuestra [guía de contribución](.github/CONTRIBUTING.md).

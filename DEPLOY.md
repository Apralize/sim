# Guía de Despliegue Rápido - SIM AI Studio

## 🚀 Inicio Rápido (5 minutos)

### 1. Verificar Requisitos
```bash
docker --version  # >= 24.0.0
docker compose version  # >= 2.20.0
```

### 2. Configurar Proyecto
```bash
# Clonar repositorio
git clone https://github.com/simstudioai/sim.git
cd sim
git checkout tags/v0.5.60 -b simstudio-0.5.60

# Configuración automática
make setup
make secrets  # Copiar los secretos generados

# Editar .env con los secretos
nano .env  # o tu editor preferido
```

### 3. Variables Mínimas Requeridas en .env
```env
# Copiar los secretos generados por 'make secrets'
BETTER_AUTH_SECRET=tu_secreto_generado_aqui
ENCRYPTION_KEY=tu_clave_generada_aqui
INTERNAL_API_SECRET=tu_secreto_generado_aqui
API_ENCRYPTION_KEY=tu_clave_generada_aqui

# Base de datos (cambiar password en producción)
POSTGRES_PASSWORD=tu_password_seguro_aqui

# URLs (ajustar según tu dominio)
NEXT_PUBLIC_APP_URL=http://localhost:3000
BETTER_AUTH_URL=http://localhost:3000
```

### 4. Iniciar Aplicación
```bash
make up
```

### 5. Verificar
```bash
make health
```

Acceder: **http://localhost:3000**

---

## 📋 Comandos Útiles

```bash
make help          # Ver todos los comandos
make status        # Estado completo del sistema
make logs          # Ver logs en tiempo real
make restart       # Reiniciar servicios
make down          # Detener servicios
make db-backup     # Backup de base de datos
```

---

## 🔧 Comandos Make Disponibles

### Configuración Inicial
- `make setup` - Configuración completa automática
- `make secrets` - Generar secretos seguros
- `make env` - Crear archivo .env

### Gestión de Servicios
- `make up` - Iniciar servicios
- `make down` - Detener servicios
- `make restart` - Reiniciar servicios
- `make status` - Ver estado completo

### Logs y Monitoreo
- `make logs` - Ver logs de todos los servicios
- `make logs-app` - Logs de la aplicación principal
- `make logs-db` - Logs de la base de datos
- `make health` - Verificar salud de servicios
- `make stats` - Ver uso de recursos

### Base de Datos
- `make db-shell` - Acceder a PostgreSQL
- `make db-backup` - Crear backup
- `make db-restore FILE=backup.sql` - Restaurar backup
- `make db-migrations` - Ejecutar migraciones

### Mantenimiento
- `make clean` - Limpiar recursos no usados
- `make update` - Actualizar a última versión
- `make pull` - Descargar últimas imágenes

### Ollama (Modelos Locales)
- `make ollama-up` - Iniciar con Ollama
- `make ollama-pull MODEL=llama3.1:8b` - Descargar modelo
- `make ollama-list` - Listar modelos instalados

---

## 🏭 Despliegue en Producción

### Checklist Pre-Producción

- [ ] **Secretos robustos** generados con `make secrets`
- [ ] **HTTPS configurado** con certificado válido
- [ ] **Firewall activo** (solo puertos 80, 443)
- [ ] **Backups automáticos** configurados
- [ ] **Monitoreo** de logs y métricas
- [ ] **Dominio configurado** en DNS
- [ ] **Reverse proxy** (Nginx/Caddy) configurado
- [ ] **Variables de producción** en .env

### Configuración de Producción

```env
# .env para producción
NODE_ENV=production

# URLs con HTTPS
NEXT_PUBLIC_APP_URL=https://tudominio.com
BETTER_AUTH_URL=https://tudominio.com
NEXT_PUBLIC_SOCKET_URL=https://tudominio.com

# Password robusta
POSTGRES_PASSWORD=genera_password_muy_segura_aqui

# Deshabilitar telemetría
NEXT_TELEMETRY_DISABLED=1
VERCEL_TELEMETRY_DISABLED=1
```

### Nginx como Reverse Proxy

Ver configuración completa en: `README.es.md` sección "Despliegue en Producción"

---

## 🐛 Solución Rápida de Problemas

### Puerto en uso
```bash
# Cambiar puerto en .env
APP_PORT=3001
```

### Recrear desde cero
```bash
make clean-all  # ⚠️ Borra todos los datos
make setup
make up
```

### Ver errores
```bash
make logs-app
```

### Verificar salud
```bash
make health
make stats
```

---

## 📚 Documentación Completa

- **Guía completa**: `README.es.md`
- **Documentación oficial**: https://docs.sim.ai
- **Código fuente**: https://github.com/simstudioai/sim

---

## 🆘 Soporte

- **Discord**: https://discord.gg/Hr4UWYEcTT
- **GitHub Issues**: https://github.com/simstudioai/sim/issues
- **Twitter/X**: @simdotai

---

**Versión**: 0.5.60 | **Licencia**: Apache 2.0

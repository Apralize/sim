# 🚀 Instrucciones de Despliegue Local - SIM AI Studio

## ⚠️ IMPORTANTE: Puerto PostgreSQL Modificado

**Se detectó que el puerto 5432 está en uso en tu sistema**, por lo tanto se ha configurado el puerto **5433** para PostgreSQL.

---

## 📋 PASO 1: Copiar .env.example a .env

```bash
cp .env.example .env
```

---

## 🔐 PASO 2: Generar Secretos Seguros

```bash
./scripts/generate-secrets.sh
```

**COPIAR LA SALIDA** y reemplazar en tu archivo `.env` las siguientes líneas:

```env
BETTER_AUTH_SECRET=<COPIAR_AQUI_EL_SECRETO_GENERADO>
ENCRYPTION_KEY=<COPIAR_AQUI_LA_CLAVE_GENERADA>
INTERNAL_API_SECRET=<COPIAR_AQUI_EL_SECRETO_GENERADO>
API_ENCRYPTION_KEY=<COPIAR_AQUI_LA_CLAVE_GENERADA>
```

---

## ✏️ PASO 3: Modificar Valores Sensibles en .env

Abre tu archivo `.env` y modifica las siguientes líneas:

### 🔴 OBLIGATORIO - Cambiar Password de PostgreSQL

```env
# ⚠️ CAMBIAR ESTE PASSWORD POR UNO SEGURO
POSTGRES_PASSWORD=tu_password_muy_seguro_aqui_cambiame
```

**Sugerencia**: Genera un password aleatorio:
```bash
openssl rand -base64 32
```

### 🟡 OPCIONAL - Configurar API Keys de IA (si las tienes)

Si tienes API keys de proveedores de IA, descomenta y configura:

```env
# OpenAI (si tienes cuenta)
# OPENAI_API_KEY=sk-...

# Anthropic Claude (si tienes cuenta)
# ANTHROPIC_API_KEY_1=sk-ant-...

# Google Gemini (si tienes cuenta)
# GEMINI_API_KEY_1=...
```

### 🟢 OPCIONAL - Email (para funcionalidad de correo)

```env
# Resend (si tienes cuenta)
# RESEND_API_KEY=re_...
# FROM_EMAIL_ADDRESS=noreply@tudominio.com
```

---

## 📝 PASO 4: Verificar tu archivo .env

Tu archivo `.env` debe tener al menos estos valores configurados:

```env
# Base de datos
DATABASE_URL="postgresql://postgres:tu_password_seguro@db:5432/simstudio"
POSTGRES_USER=postgres
POSTGRES_PASSWORD=tu_password_seguro  # ⚠️ CAMBIAR
POSTGRES_DB=simstudio
POSTGRES_PORT=5433  # Puerto modificado porque 5432 está en uso

# Seguridad - Secretos generados
BETTER_AUTH_SECRET=secreto_de_64_caracteres_hex_generado
ENCRYPTION_KEY=secreto_de_64_caracteres_hex_generado
INTERNAL_API_SECRET=secreto_de_64_caracteres_hex_generado
API_ENCRYPTION_KEY=secreto_de_64_caracteres_hex_generado

# URLs de la aplicación (dejar como están para local)
NEXT_PUBLIC_APP_URL=http://localhost:3000
BETTER_AUTH_URL=http://localhost:3000

# Socket (dejar como está para local)
SOCKET_SERVER_URL=http://localhost:3002
NEXT_PUBLIC_SOCKET_URL=http://localhost:3002
SOCKET_PORT=3002

# Ollama (si quieres usar modelos locales)
OLLAMA_URL=http://localhost:11434
```

---

## 🚀 PASO 5: Desplegar en Local

```bash
# Verificar que Docker está corriendo
docker info

# Iniciar servicios
make up

# O si no tienes make instalado:
docker compose up -d
```

---

## ✅ PASO 6: Verificar que Todo Funciona

```bash
# Verificar estado de servicios
make health

# Ver logs
make logs

# Ver contenedores corriendo
docker compose ps
```

**Acceder a la aplicación**: http://localhost:3000

---

## 🔍 Verificación Paso a Paso

### 1. Verificar que los contenedores están corriendo

```bash
docker compose ps
```

Deberías ver:
- ✅ simstudio-app (healthy)
- ✅ simstudio-realtime (healthy)
- ✅ simstudio-db (healthy)
- ✅ simstudio-migrations (exited - esto es normal)

### 2. Verificar logs por si hay errores

```bash
# Logs de la aplicación principal
docker compose logs simstudio

# Logs de la base de datos
docker compose logs db

# Logs del servidor realtime
docker compose logs realtime
```

### 3. Acceder a la aplicación

Abre tu navegador en: **http://localhost:3000**

---

## 🐛 Solución de Problemas

### Problema: "Port already in use"

Si ves este error, significa que algún puerto sigue en uso:

**Solución 1**: Cambiar puertos en `.env`
```env
APP_PORT=3001      # Cambiar si 3000 está en uso
SOCKET_PORT=3003   # Cambiar si 3002 está en uso
POSTGRES_PORT=5434 # Cambiar si 5433 está en uso
```

Después de cambiar, reiniciar:
```bash
make down
make up
```

**Solución 2**: Detener servicios que usan esos puertos
```bash
# Ver qué está usando el puerto
sudo lsof -i :3000
sudo lsof -i :5433

# Detener el servicio
sudo systemctl stop <nombre_servicio>
```

### Problema: "Database connection failed"

```bash
# Verificar que PostgreSQL está corriendo
docker compose logs db

# Reiniciar servicios
make restart
```

### Problema: "Secrets validation failed"

Significa que los secretos no son suficientemente seguros.

**Solución**:
```bash
# Generar nuevos secretos
./scripts/generate-secrets.sh

# Copiarlos en .env
nano .env
```

---

## 📊 Comandos Útiles Post-Despliegue

```bash
# Ver estado
make status

# Ver logs en tiempo real
make logs

# Reiniciar servicios
make restart

# Detener servicios
make down

# Backup de base de datos
make db-backup

# Ver uso de recursos
make stats

# Acceder a PostgreSQL
make db-shell
```

---

## 🎯 Checklist Final

Antes de considerar el despliegue exitoso, verifica:

- [ ] Archivo `.env` creado y configurado
- [ ] Secretos generados y copiados en `.env`
- [ ] Password de PostgreSQL cambiado
- [ ] Servicios corriendo: `docker compose ps`
- [ ] Health checks pasando: `make health`
- [ ] Aplicación accesible en http://localhost:3000
- [ ] Sin errores en logs: `make logs`
- [ ] Puedes crear una cuenta y hacer login

---

## 📋 Resumen de Valores que DEBES Cambiar

| Variable | Valor por Defecto | Acción Requerida |
|----------|-------------------|------------------|
| `BETTER_AUTH_SECRET` | (vacío) | ✅ Generar con script |
| `ENCRYPTION_KEY` | (vacío) | ✅ Generar con script |
| `INTERNAL_API_SECRET` | (vacío) | ✅ Generar con script |
| `API_ENCRYPTION_KEY` | (vacío) | ✅ Generar con script |
| `POSTGRES_PASSWORD` | `postgres` | ⚠️ CAMBIAR obligatorio |
| `OPENAI_API_KEY` | (vacío) | 🔵 Opcional si tienes cuenta |
| `ANTHROPIC_API_KEY_1` | (vacío) | 🔵 Opcional si tienes cuenta |
| `GEMINI_API_KEY_1` | (vacío) | 🔵 Opcional si tienes cuenta |
| `RESEND_API_KEY` | (vacío) | 🔵 Opcional para emails |

---

## ⏭️ Siguiente Paso: Despliegue en VPS

Una vez que el despliegue local funcione correctamente, podemos proceder con el despliegue en tu VPS de producción.

Para eso necesitaremos:
- IP o dominio de tu VPS
- Configurar HTTPS con certificado SSL
- Configurar firewall
- Configurar backups automáticos

---

**¿Todo funcionando en local?** Ejecuta:
```bash
make status
```

Si todo está ✅, estás listo para producción.

# Guía de Despliegue Remoto KODA

Esta guía detalla la arquitectura "KODA GitOps" para desplegar agentes en entornos de producción.

## Filosofía: Inmutabilidad

El principio fundamental es que **el servidor nunca edita sus propias definiciones**.

- **Definiciones (Agentes/Guías)**: Fluyen unidireccionalmente `Local -> Git -> Server`.
- **Estado (Memoria/Logs)**: Se persiste localmente en el servidor o BD, nunca en el repo de definiciones.
- **Aprendizaje**: Si el agente propone cambios, lo hace via Pull Request (no auto-edición).

## Infraestructura

El framework incluye una solución de despliegue "out-of-the-box" en `infrastructure/`.

### Componentes

1. **Dockerfile**: Entorno Python/Node con las herramientas CLI de KODA preinstaladas.
2. **Entrypoint (`entrypoint.sh`)**: Script inteligente que clona el repo, inyecta configuración de producción y vigila cambios (polling).
3. **Config Overlay (`resolver.prod.yml`)**: Sobreescribe las rutas relativas locales con rutas absolutas del contenedor (`/opt/koda/...`).

## Cómo Desplegar

### 1. Variables de Entorno

Crea un archivo `.env` en tu servidor (o en CI/CD):

```bash
KODA_REPO_URL=https://github.com/tu-usuario/tu-namespace.git
KODA_BRANCH=main
```

### 2. Ejecutar con Docker Compose

```bash
cd infrastructure
docker-compose up -d --build
```

El contenedor:

1. Clonará tu repositorio.
2. Validará la estructura (`koda validate`).
3. Inyectará el resolver de producción.
4. Entrará en un bucle de vigilancia, haciendo `git pull` cada 60 segundos automáticamente.

## Gestión de Cambios (GitOps)

### Para Actualizar un Agente

1. Edita el archivo en tu laptop: `agents/mi-agente.yaml`.
2. Commit y Push: `git push origin main`.
3. El servidor detectará el cambio en el siguiente ciclo (o via webhook) y recargará.

## Despliegue de Federación Completa (Multi-Namespace)

Para desplegar **todos** los namespaces (koda, sanixai, etc.) en un solo servidor y que interactúen entre sí.

### Paso 1: Preparar el Servidor

Asegúrate de tener Docker y Docker Compose instalados.

```bash
# En tu servidor remoto (ssh user@server)
mkdir -p /opt/koda-infra
cd /opt/koda-infra
# Copia el contenido de la carpeta infrastructure/ local aquí
```

### Paso 2: Configurar Repositorios

Edita el archivo `docker-compose.yml` (o usa variables de entorno) para definir `KODA_REPOS_MAP`.
El formato es `namespace=url;namespace2=url2`.

```yaml
    environment:
      - KODA_REPOS_MAP=koda=https://github.com/felix-antonio-sl/koda_.git;sanixai=https://github.com/felix-antonio-sl/sanixai.git;gorenuble=https://github.com/felix-antonio-sl/gorenuble.git
      - KODA_BRANCH=develop
```

### Paso 3: Arrancar Federación

```bash
docker-compose up -d --build
```

El contenedor:

1. Iterará sobre cada namespace definido.
2. Clonará cada repo en `/opt/koda/repos/{namespace}`.
3. Inyectará el `resolver.prod.yml` maestro en cada uno.

### Paso 4: Verificar Estado

Revisa los logs para asegurar que todos los repos se sincronizaron:

```bash
docker logs -f koda_federation_01
```

Deberías ver "📦 Syncing Namespace: sanixai...", "📦 Syncing Namespace: koda...", etc.

### Paso 5: Persistencia

Los repositorios se guardan en el volumen Docker `koda_repos`. Si reinicias el contenedor, no se volverán a clonar desde cero, solo se hará `git pull` para actualizar cambios.

## Acceso a Archivos y Conocimiento

Una vez desplegado, tienes tres formas de interactuar con los archivos de `knowledge/`, `agents/` y `skills/`:

### 1. Acceso Interno (Para el Agente)
El **KODA Resolver** se encarga de todo. Gracias a la regla comodín en `resolver.prod.yml`, cualquier agente dentro del contenedor puede resolver URNs de cualquier namespace:
- URN: `urn:knowledge:sanixai:core:guia:1.0.0`
- Ruta Interna: `/opt/koda/repos/sanixai/knowledge/core/guia_...yml`

**No necesitas saber la ruta física**, el agente la encuentra solo pidiendo la URN.

### 2. Inspección Manual (Desde el Host)
Si quieres ver los archivos físicos en el servidor sin entrar al contenedor, puedes encontrarlos en el path de volúmenes de Docker (normalmente `/var/lib/docker/volumes/...`). 

Sin embargo, la forma más limpia es usar `docker exec`:
```bash
# Listar guías de un namespace específico
docker exec koda_federation_01 ls -R /opt/koda/repos/sanixai/knowledge
```

### 3. Exposición vía Volumen (Recomendado para Edición/Lectura externa)
Si necesitas que una aplicación externa (ej: un servidor web o un buscador) lea estos archivos, puedes mapear el volumen a una ruta conocida en tu `docker-compose.yml`:

```yaml
    volumes:
      - /path/en/tu/servidor/repos:/opt/koda/repos  # Mapeo directo al host
```
De esta forma, los archivos aparecerán en `/path/en/tu/servidor/repos/koda/knowledge/...` y podrás verlos con cualquier herramienta del servidor.

> [!WARNING]
> Aunque los veas en el host, **recuerda la regla de oro**: No edites directamente en el servidor si quieres mantener la sincronización con Git. Los cambios hechos a mano serán sobreescritos por el próximo `git pull` automático.

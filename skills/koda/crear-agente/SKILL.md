---
name: crear-agente
description: Crea un nuevo agente KODA con toda la estructura de directorios y archivos estándar. Úsese cuando el usuario quiera "crear un nuevo agente" o "inicializar un agente".
disable-model-invocation: false
allowed-tools: Write, List, Read, Run
---

# Crear Agente KODA

Esta skill automatiza la creación de un nuevo agente siguiendo el estándar KODA/Agent.

## Uso
Cuando el usuario solicite crear un agente (ej: "Crear agente procesador-datos"), sigue estos pasos:

1.  **Determinar Nombre e ID**:
    *   Nombre: El que indique el usuario (ej: `procesador-datos`).
    *   ID: Convertir a `SCREAMING_SNAKE_CASE` (ej: `PROCESADOR_DATOS`).
    *   Ruta: `agents/agent_[nombre].yaml`.

2.  **Leer Plantilla**:
    *   Lee el contenido de `templates/agent.yaml` ubicado en este directorio.

3.  **Generar Contenido**:
    *   Reemplaza `${NAMESPACE}` por el namespace actual del proyecto (busca en `.knowledge-resolver.yml` o usa `koda` por defecto).
    *   Reemplaza `${AGENT_ID}` con el ID calculado.
    *   Reemplaza `${TITLE}` con un título human-readable.
    *   Reemplaza `${DATE}` con la fecha actual (YYYY-MM-DD).
    *   Reemplaza `${DESCRIPTION}` con una descripción breve (si el usuario la dio) o un placeholder.

4.  **Escribir Archivo**:
    *   Crea el archivo en la ruta destino `agents/agent_[nombre].yaml` (asegura que el directorio exista).

5.  **Instrucciones Finales**:
    *   Indica al usuario que ejecute `koda skills sync` si es necesario.
    *   Sugiere validar con `git add` y `git commit`.

## Sincronización
Al finalizar, **SIEMPRE** instruye ejecutar:
```bash
koda skills sync --local
```
para asegurar que cualquier recurso local se propague.

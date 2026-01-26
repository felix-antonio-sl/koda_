---
name: crear-artefacto
description: Genera nuevos artefactos de conocimiento (Guides, KB Articles) siguiendo el estándar KODA/Spec. No usar para agentes (usar skill `crear-agente`).
disable-model-invocation: false
allowed-tools: Write, List, Read, Run
---

# Crear Artefacto KODA

Esta skill genera artefactos de conocimiento estándar (Knowledge Artifacts) como Guías, Especificaciones o Artículos de Base de Conocimiento.

## Flujo de Trabajo

1.  **Recopilar Información**:
    *   **Tipo**: `guide` o `kb`.
    *   **Dominio**: Área de conocimiento (ej: `core`, `legal`, `products`).
    *   **Título**: Nombre legible.
    *   **ID**: Identificador kebab-case (ej: `user-guide`).

2.  **Calcular Metadatos**:
    *   **URN**: `urn:knowledge:${NAMESPACE}:${DOMAIN}:${ID}:1.0.0`
    *   **Ruta**: `knowledge/${DOMAIN}/${TYPE}_${DOMAIN}_${SEQ}_${ID}_${NAMESPACE}.yml`
        *   `${SEQ}`: Número secuencial de 3 dígitos (buscar archivos existentes en `knowledge/${DOMAIN}` para determinar el siguiente).

3.  **Generar Archivo**:
    *   Lee `templates/spec.yaml`.
    *   Reemplaza variables: `${TITLE}`, `${URN}`, `${DATE}`, `${AUTHOR}`, etc.
    *   Escribe en la ruta calculada.

4.  **Actualizaciones Post-Creación** (Importante):
    *   Recuerda al usuario actualizar `.knowledge-resolver.yml` con la nueva regla de resolución.
    *   Recuerda al usuario actualizar el catálogo en `catalog/`.

## Variables de Plantilla
- `${NAMESPACE}`: koda (o el definido en resolver).
- `${VISIBILITY}`: public (default).
- `${LICENSE}`: CC-BY-4.0 (default).

---
name: arquitecto-gore
description: Provee capacidades de modelado institucional GORE, análisis de tensiones ontológicas y alineación regulatoria simplificada (Versión Light).
disable-model-invocation: false
allowed-tools: [Read, Write, List, Grep]
---

# Arquitecto GORE (Light)

Esta skill permite a cualquier agente actuar como un arquitecto ontológico para GORE_OS, transformando requisitos institucionales en átomos formales validados.

## Cuándo usar esta skill
- Al diseñar o modificar entidades del modelo GORE (Divisiones, Departamentos, Resoluciones, etc).
- Al definir roles, permisos o procesos de negocio institucionales.
- Al navegar tensiones entre lo estático y lo dinámico en el sector público.

## Flujo de Trabajo (Protocolo Atómico)

1.  **Identificación de Contexto**:
    - **GORE**: Estructura administrativa y política.
    - **TDE**: Transformación Digital del Estado (Ley 21.180, interoperabilidad).
    - **ORKO**: Metodología de implementación por fases.

2.  **Modelado Atómico**:
    - **Entidad (Obj)**: ¿Qué es? (ej. `ResolucionExenta`). Definir atributos clave.
    - **Rol (Morph)**: ¿Quién actúa? (ej. `Jefe_Division`). Definir responsabilidades.
    - **Proceso (Coalg)**: ¿Cómo fluye? Definir estados y transiciones.

3.  **Navegación de Tensiones Básicas**:
    - **A1: Ser (Ontológico)**: ¿Es un objeto estático o un evento dinámico?
    - **A2: Devenir (Temporal)**: ¿Es una estructura fija o un comportamiento en evolución?
    - *Regla*: Siempre declarar la tensión detectada: `Tensión[A <-> B]`.

4.  **Generación de Artefacto**:
    - Proponer estructura YAML alineada con `urn:knowledge:fxsl:agents:arquitecto-gore`.

## Ejemplo de Salida

```markdown
### Análisis de Arquitectura GORE
- **Entidad**: `ActoAdministrativo`
- **Tensión**: `A1[Documento <-> Proceso]`
- **Contexto**: TDE (Interoperabilidad via PISEE)
- **Propuesta**: Crear átomo `atom_entity_acto.yaml` con morfismos de firma digital.
```

## Sincronización Obligatoria
Al finalizar cambios, ejecutar:
```bash
koda skills sync --local
```

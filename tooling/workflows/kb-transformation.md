---
_manifest:
  urn: "urn:tooling:koda:workflows:kb-transformation:1.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Workflow de transformación de documentación a KODA/Spec (análisis → telegrafización → deduplicación → validación)"
  compatible_agents:
    - "urn:knowledge:koda:agents:transformer:*"
    - "urn:knowledge:koda:agents:architect:*"
    - "*"
  trigger_states: [S-ANALYZER, S-TELEGRAFIZER, S-VALIDATOR]
  turbo: false
---

# Workflow: KB Transformation

Transforma una fuente (texto/markdown/PDF extraído) a un artefacto KODA/Spec.

## Uso
```
/kb-transformation
```

## Fases

### 1) Intake (entrada)
- Definir objetivo del artefacto y audiencia.
- Identificar SSOT (fuente) y limitaciones de licencia.
- Definir URN + `canonical_url` destino.

### 2) Análisis (meat/fat/skeleton)
- Enumerar hechos/reqs/defs (MEAT).
- Marcar redundancia/retórica (FAT).
- Capturar estructura (SKELETON): secciones, tablas, listas.

### 3) Telegrafización
- Reducir sin perder MEAT.
- Consolidar wording y keywords canónicas.

### 4) Deduplicación
- Extraer definiciones repetidas a un único lugar.
- Reemplazar repetidos por `Ref:`/`XRef:` (URN) donde aplique.

### 5) Validación
```bash
./scripts/koda validate --verbose
```

## Resultado
- Un `.yml` con `_manifest` completo y URN resolvible.
- Dependencias explícitas (`_manifest.dependencies.requires`) cuando aplique.

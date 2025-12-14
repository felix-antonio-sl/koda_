---
_manifest:
  urn: "urn:tooling:koda:workflows:kb-transformation:1.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Workflow de transformación de documentos a KODA/Spec"
  compatible_agents:
    - "urn:knowledge:koda:agents:transformer:*"
    - "urn:knowledge:koda:agents:architect:*"
  trigger_states: [S-TRANSFORMER, S-ANALYZER]
  platforms: [antigravity, windsurf, cursor]
  turbo: false
---

# Workflow: Transformación de Documentos a KODA

Este workflow guía la transformación de documentos textuales a artefactos KODA/Spec.

## Fases

### 1. Análisis (Meat/Fat/Skeleton)

Escanear documento identificando:

- **MEAT**: Hechos, datos, requisitos, definiciones (preservar 100%)
- **FAT**: Filler, retórica, redundancia (eliminar)
- **SKELETON**: Jerarquía, tablas, listas (mantener estructura)

### 2. Telegrafización

Aplicar transformación:

- Eliminar fat (palabras de relleno, muletillas)
- Aplicar keywords Tier 1 (ID, Ref, Def, Act, Cond, Res, Req, Ctx, Ex, etc.)
- Aplicar keywords Tier 2 (dominio específico, Snake_Case)
- Mantener densidad informacional alta

### 3. Deduplicación

Consolidar información repetida:

- Identificar conceptos duplicados
- Crear definición única con ID
- Reemplazar ocurrencias con Ref: ID
- Verificar ratio deduplicación RD ≥ 2.0

### 4. Validación

Verificar métricas de calidad:

- TER (Token Economy Ratio) ≥ 30%
- FS (Fidelity Score) = 100%
- RD (Redundancy Deduplicated) ≥ 2.0
- YAML válido con _manifest

## Métricas

| Métrica | Fórmula                               | Objetivo |
| ------- | ------------------------------------- | -------- |
| TER     | 1 - (tokens_koda / tokens_original)   | ≥ 30%    |
| FS      | hechos_preservados / hechos_original  | 100%     |
| RD      | conceptos_total / definiciones_unicas | ≥ 2.0    |

## Comando

Ejecutar transformación con KODA-TRANSFORMER.

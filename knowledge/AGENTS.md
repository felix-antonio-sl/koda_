# Knowledge Base Guidelines - KODA/Spec

Al trabajar con artefactos de conocimiento en este directorio:

## Workflow de Transformación

Para crear o modificar artefactos KODA: `/kb-transformation`

Este workflow guía a través de las 4 fases:
1. Análisis (Meat/Fat/Skeleton)
2. Telegrafización (keywords + densidad)
3. Deduplicación (Ref: mechanism)
4. Validación (TER≥30%, FS=100%, RD≥2.0)

## Formato KODA/Spec

### Obligatorio
```yaml
_manifest:
  urn: "urn:knowledge:{namespace}:{domain}:{artifact}:{version}"
  # ... metadata

LLM_Parsing_Instructions:
  # Lexicon y reglas para LLM
```

### Keywords Tier 1
- `ID:` - Identificador único
- `Def:` - Definición
- `Ref:` - Referencia interna
- `XRef:` - Referencia externa (URN)
- `Purp:`, `Obj:`, `Ctx:`, etc.

### Convenciones
- Telegráfico: denso, sin fat
- Deduplicación: definir una vez, referenciar múltiples
- YAML válido y estricto

## Referencias

- Spec: `urn:knowledge:koda:core:spec:1.0.0`
- Transform: `urn:knowledge:koda:core:transform:1.0.0`
- Rules: `tooling/rules/yaml-strict.yml`

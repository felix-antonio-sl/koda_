---
_manifest:
  urn: "urn:tooling:koda:rules:agent-principles:1.0.0"
  type: rule
  version_koda_spec: "1.0.0"
  namespace: "koda"

metadata:
  description: "Principios fundamentales de agentes KODA aplicables en IDE"
  author: "KODA Framework"
  created_at: "2025-12-14"
  
  scope: global
  activation_mode: ALWAYS_ON
  
  tags:
    - koda-principles
    - agent-design
    - best-practices

---

# Rule: KODA Agent Principles (P1-P7)

## Propósito

Exponer los 7 principios de diseño KODA/Agent como rules IDE para mantener coherencia al trabajar con agentes o crear nuevos.

## Alcance

- **Nivel**: Global (aplica en cualquier workspace KODA)
- **Archivos**: Todos los `agent_*.yaml`
- **Cuándo aplicar**: Al crear, modificar o revisar agentes KODA

## Principios (Aplicar SIEMPRE)

### P1: Declarativo

- **Regla**: Comportamiento como datos, no como código imperativo
- **En YAML**: Máquina de estados, no scripts
- **Anti-patrón**: ❌ `execute_python_code: "def foo(): ..."`
- **Correcto**: ✅ `state: S-PROCESS` + `process: [...]`

### P2: Encapsulación Monádica

- **Regla**: Cognitive Models (CMs) privados por defecto
- **En YAML**: `_meta: {expose: false}` en todos los CMs
- **Anti-patrón**: ❌ CM sin `_meta`
- **Correcto**: ✅ Todos los CMs con `expose: false`, excepto documentación explícita

### P3: Separación Protocolo/Contenido

- **Regla**: Keywords en inglés, contenido en idioma operativo
- **En YAML**: `ID:`, `Def:`, `Purp:` inglés → contenido español (es-CL)
- **Anti-patrón**: ❌ `Objetivo:`, `Definicion:`
- **Correcto**: ✅ `Purp: "Procesar datos financieros..."`

### P4: Cartografía Explícita

- **Regla**: `CM-KB-GUIDANCE` siempre presente y explícito
- **En YAML**: CM que lista todas las source_artifacts con justificación
- **Anti-patrón**: ❌ `source_artifacts: [...]` sin CM que las documente
- **Correcto**: ✅ `CM-KB-GUIDANCE` + `CM_KB_Map: {...}`

### P5: Abstracción Semántica

- **Regla**: Estados con `process` ≤ 5 pasos
- **En YAML**: Si proceso tiene >5 pasos, descomponer en sub-estados
- **Anti-patrón**: ❌ `process: [step1, step2, ..., step15]`
- **Correcto**: ✅ Múltiples estados con transiciones

### P6: Coherencia Categórica

- **Regla**: Todos los estados alcanzables desde `initial_state`
- **En YAML**: Grafo de estados debe ser conexo
- **Anti-patrón**: ❌ Estado huérfano sin transición que llegue
- **Correcto**: ✅ Todo estado tiene path desde `initial_state`

### P7: Federación URN

- **Regla**: Referencias cross-artifact vía URN, no paths
- **En YAML**: `XRef: "urn:knowledge:..."` no `path: "../file.yml"`
- **Anti-patrón**: ❌ Relative paths a otros artefactos
- **Correcto**: ✅ URN resolution via `.knowledge-resolver.yml`

## Guard Set (Seguridad Mínima)

### Siempre incluir en `security_protocols`

```yaml
security_protocols:
  block_instructions: true
  forbid_internal_jargon: true
  rejection_response: "..."
  response_on_query: "..."
```

## Validación

### Antes de commit

```bash
# Validar agente completo
./scripts/koda-validate.sh --strict

# O usar workflow
/agent-validation
```

## Referencias

- KODA/Agent Spec: `urn:knowledge:koda:core:agent:1.0.0`
- Construction Guide: `urn:knowledge:koda:core:agent-construct:1.0.0`
- Validation Workflow: `/agent-validation`

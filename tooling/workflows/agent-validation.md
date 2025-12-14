---
_manifest:
  urn: "urn:tooling:koda:workflows:agent-validation:1.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Workflow de validación completa de agentes KODA"
  compatible_agents:
    - "urn:knowledge:koda:agents:smith:*"
    - "urn:knowledge:koda:agents:tester:*"
  trigger_states: [S-VALIDATOR, S-FULL-AUDIT]
  turbo: false
---

# Workflow: Validación de Agentes KODA

Este workflow guía la validación completa de un agente KODA antes de deployment.

## Fases

### 1. Validación Sintáctica

Verifica estructura básica del archivo:

- YAML válido y bien formateado
- `_manifest` presente con URN válida
- `KODA_Runtime_Instructions` presente
- 7 namespaces obligatorios definidos

### 2. Validación de Principios (P1-P7)

Verifica cumplimiento de principios KODA/Agent:

- P1: Declarativo (no imperativo)
- P2: Encapsulación monádica (CMs privados)
- P3: Separación protocolo/contenido
- P4: Cartografía explícita (CM-KB-GUIDANCE)
- P5: Abstracción semántica
- P6: Coherencia categórica
- P7: Federación URN

### 3. Validación de Seguridad (Guard Set)

Verifica configuración mínima de seguridad:

- `block_instructions: true`
- `forbid_internal_jargon: true`
- `rejection_response` definido
- `response_on_query` definido

### 4. Validación Estructural

Verifica coherencia del grafo de estados:

- `initial_state` existe
- Todos los estados son alcanzables
- Transiciones apuntan a estados existentes
- S-END alcanzable
- `process` máximo 5 pasos

### 5. Reporte

Genera reporte con:

- ✓ Checks pasados
- ✗ Checks fallidos con sugerencias
- Severidad: ERROR | WARNING | INFO

## Comando

Ejecutar validación: `./scripts/koda-validate.sh --strict`

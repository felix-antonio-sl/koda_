---
_manifest:
  urn: "urn:tooling:koda:workflows:agent-validation:1.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Workflow de validación completa de agentes KODA (schema + convenciones)"
  compatible_agents:
    - "urn:knowledge:koda:agents:smith:*"
    - "urn:knowledge:koda:agents:tester:*"
    - "*"
  trigger_states: [S-VALIDATOR, S-FULL-AUDIT]
  turbo: false
---

# Workflow: Agent Validation

Validación end-to-end de un `agent_*.yaml` contra el schema KODA y convenciones del repo.

## Uso
```
/agent-validation [ruta_agent.yaml]
```

## Pasos (recomendado)

### 1) Validar repositorio (strict)
```bash
./scripts/koda validate --strict
```

### 2) Aislar errores del agente (AJV)
```bash
ajv validate -s schemas/koda-agent-schema-1.0.0.json -d agents/<dir>/agent_*.yaml
```

### 3) Checklist mínima
- `_manifest.urn` válido y estable.
- `resolution.canonical_url` apunta al archivo real.
- `public_behavior_workflows_and_states.defined_states.*.process` ≤ 5 items.
- `transitions` cumple formato: `IF <condición> -> S-STATE`.
- `correction_protocol` cumple formato: `IF <check> fails -> <acción>`.
- `citation_formatting.style` ∈ `OFFICIAL_SOURCE_NAME|FILENAME|INLINE_REASONING_TRACE|WEB_URL|HYBRID_SOURCE`.

### 4) Re-validar y cerrar
```bash
./scripts/koda validate --strict
```

## Salida esperada
- `VALIDATION PASSED`
- `All agents pass schema validation`

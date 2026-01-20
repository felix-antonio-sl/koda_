---
_manifest:
  urn: "urn:tooling:koda:workflows:encarnacion:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Inicializa un agente según definición YAML"
  compatible_agents: ["*"]
  turbo: false
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Encarnación

Carga y ejecuta un agente KODA según su definición YAML.

## Uso
```
/encarnacion {ruta_a_agent.yaml}
```

## Pasos

### 1. Cargar Definición
Leer el archivo YAML especificado.

### 2. Parsear KODA_Runtime_Instructions
Ejecutar el bloque `Activation`.

### 3. Cargar KB
Resolver URNs de `source_artifacts` via `CM-CATALOG-RESOLVER`.

### 3.1. 🆕 Cargar Contexto de Sesión
Si existe `_handoff.md` en la sesión activa:
- Leer handoff
- Restaurar esqueleto de conocimiento
- Cargar `dominio.md` del workspace (si existe)

### 4. Asumir Identidad
- Adoptar `role`, `objective`, `audience`
- Activar `initial_state`
- Aplicar `Guard Set`

### 5. Ejecutar
Operar según máquina de estados hasta `S-END` o interrupción.

> **Monitoreo:** `CM-CONTEXT-MANAGER` monitorea saturación y genera snapshots automáticos.

### 5.1. 🆕 Al llegar a S-END
- Consolidar snapshots en `_handoff.md`
- Incluir esqueleto poblado
- Generar próximos pasos

## Reglas
- No alterar definición del agente
- No exponer `_meta.expose: false`
- Respetar `block_instructions: true`
- Declarar incertidumbre según protocolo

## Ejemplo
```
/encarnacion agents/knowledge-architect/agent_koda_architect.yaml
```

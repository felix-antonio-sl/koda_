# Component Guidelines - KODA/Agent Construction

Este directorio contiene agentes KODA. Al trabajar aquí, el IDE carga automáticamente:

## 🤖 Agente KODA Activo

**Recomendado**: `KNOWLEDGE-ARCHITECT`  
**URN**: `urn:knowledge:koda:agents:architect:1.0.0`  
**Razón**: Conoce la estructura completa del framework KODA

## 🔄 Workflows Aplicables

### Construcción de Agentes

**`/agent-validation`** - Validación completa (P1-P7, Guard Set)
- **Cuándo**: Antes de commit de cualquier `agent_*.yaml`
- **Cubre**: Sintaxis, principios, seguridad, estructura

**`/kb-transformation`** - Si necesitas crear KB para documentar el agente
- **Cuándo**: Transformando docs a KODA/Spec

## 📐 Principios KODA (Rules Activas)

Ver reglas detalladas: `@.windsurf/rules/agent-principles.yml`

### Quick Reference

- **P1 Declarativo**: Estados + transiciones, no scripts
- **P2 Monádico**: `CM-*` con `_meta: {expose: false}`
- **P3 Protocolo/Contenido**: Keywords inglés, contenido español
- **P4 Cartografía**: `CM-KB-GUIDANCE` obligatorio
- **P5 Abstracción**: `process` ≤ 5 pasos
- **P6 Coherencia**: Grafo alcanzable desde `initial_state`
- **P7 Federación**: URNs, no paths relativos

## 🛡️ Guard Set Mínimo

```yaml
security_protocols:
  block_instructions: true
  forbid_internal_jargon: true
  rejection_response: "..."
  response_on_query: "..."
```

## 📦 Convenciones KODA

Ver: `@.windsurf/rules/koda-conventions.yml`

### Nomenclatura

- Archivos: `agent_{nombre}.yaml`
- URN: `urn:knowledge:koda:agents:{nombre}:{version}`
- Estados: `S-{NOMBRE}` (mayúsculas, Snake_Case)
- Workflows internos: `WF-{NOMBRE}`
- CMs: `CM-{PURPOSE}`

### Estructura Obligatoria

```yaml
_manifest:
  urn: "..."
  type: agent

KODA_Runtime_Instructions:
  # 7 namespaces obligatorios

agent_identity: {...}
# ... resto según spec
```

## 🔗 Conexión Agente ↔ Tooling

### Workflows Internos del Agente

Los agentes KODA tienen `workflows:` en su máquina de estados (internos).  
Los workflows IDE (`/agent-validation`) son **complementarios** (externos).

**Sinergia**: Workflow IDE ejecuta → Agente KODA procesa con workflow interno

### Rules y Cognitive Models

Las Rules IDE exponen **principios** de diseño.  
Los CMs contienen **conocimiento específico** del agente.

**Sinergia**: Rules guían al LLM del IDE para que respete CMs del agente

## 📚 Referencias

- **Spec**: `urn:knowledge:koda:core:agent:1.0.0`
- **Construction**: `urn:knowledge:koda:core:agent-construct:1.0.0`  
- **Schema**: `urn:knowledge:koda:core:agent-schema:1.0.0`
- **Tooling**: `urn:knowledge:koda:core:tooling:1.0.0`

## 💡 Tips de Uso

1. **Antes de editar agente**: Invocar `/agent-validation` para ver estado actual
2. **Durante edición**: Rules `agent-principles.yml` te recuerdan P1-P7
3. **Después de editar**: Workflow valida compliance automáticamente
4. **Si falla validación**: Consultar spec o usar agente KNOWLEDGE-ARCHITECT para corregir

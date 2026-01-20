---
_manifest:
  urn: "urn:tooling:koda:workflows:catalogo-sesiones:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Catálogo centralizado de workspaces y sesiones con encadenamiento"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Catálogo de Sesiones

Gestiona un registro centralizado de todas las sesiones de trabajo.

> **SSOT:** El catálogo es global en `~/.gemini/antigravity/sesiones/catalogo.yml`

## Archivo de Catálogo
Ubicación: `~/.gemini/antigravity/sesiones/catalogo.yml`

## Comandos

### Ver árbol de sesiones
// turbo
```bash
CATALOGO="$HOME/.gemini/antigravity/sesiones/catalogo.yml"
if [ -f "$CATALOGO" ]; then
   cat "$CATALOGO"
else
   echo "📋 Catálogo no existe. Creando..."
   mkdir -p "$HOME/.gemini/antigravity/sesiones"
   echo "# Catálogo de Sesiones" > "$CATALOGO"
   echo "version: 1.0" >> "$CATALOGO"
   echo "created: $(date -Iseconds)" >> "$CATALOGO"
   echo "sesiones: []" >> "$CATALOGO"
   echo "✅ Catálogo creado: $CATALOGO"
fi
```

### Listar sesiones recientes
// turbo
```bash
SESSION_BASE="$HOME/.gemini/antigravity/sesiones"
echo "📂 Sesiones disponibles:"
ls -lt "$SESSION_BASE" 2>/dev/null | grep -v catalogo | head -10
```

### Buscar por tag
// turbo
```bash
TAG=$1
CATALOGO="$HOME/.gemini/antigravity/sesiones/catalogo.yml"
if [ -f "$CATALOGO" ]; then
   grep -A5 "$TAG" "$CATALOGO" 2>/dev/null || echo "No encontrado: $TAG"
fi
```

## Estructura de Datos

```yaml
version: 1.0
created: 2026-01-19T00:00:00-03:00

sesiones:
  - id: "sesion-padre"
    nombre: "Diseño API"
    estado: "cerrada"
    workspace: "/path/to/workspace"
    cadena:
      tipo: "bifurcacion"
      siguientes: ["rama-a", "rama-b"]

  - id: "rama-a"
    nombre: "Impl. REST"
    estado: "activa"
    workspace: "/path/to/workspace"
    cadena:
      tipo: "continuacion"
      anterior: "sesion-padre"
      rama: "REST"
```

## Visualización Árbol

```
Diseño API (cerrada)
├── Impl. REST (activa) 🟢
└── Impl. GraphQL (standby) 🟡
```


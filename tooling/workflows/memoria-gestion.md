---
_manifest:
  urn: "urn:tooling:koda:workflows:memoria-gestion:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Gestión de memoria en 3 niveles (global/workspace/sesión)"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Gestión de Memoria

Sistema de memoria complementario a Knowledge Items nativos de Antigravity.

> **SSOT:** Las sesiones son globales en `~/.gemini/antigravity/sesiones/`

## Niveles de Alcance

| Nivel     | Ubicación                                | Uso                              |
| --------- | ---------------------------------------- | -------------------------------- |
| Global    | `~/.gemini/user/`                        | Conocimiento personal permanente |
| Workspace | `{workspace}/.antigravity/conocimiento/` | Dominio del proyecto             |
| Sesión    | `~/.gemini/antigravity/sesiones/{id}/`   | Snapshots y handoffs             |

## Comandos

```
/memoria-gestion {nivel} ver
/memoria-gestion {nivel} agregar {archivo.md}
/memoria-gestion sesion limpiar
```

## Estructura de Archivos

```
~/.gemini/                             # RAÍZ GLOBAL
├── GEMINI.md                          # Reglas globales
├── user/                              # GLOBAL USER
│   ├── glosario.md
│   ├── convenciones.md
│   └── rules/
└── antigravity/
    ├── knowledge/                     # Knowledge Items nativos (NO TOCAR)
    ├── skills/                        # Skills globales
    │   └── context-manager/           # 🆕 Skill de gestión de contexto
    └── sesiones/{id}/                 # SESIÓN GLOBAL
        ├── _snapshot_*.md             # Capturas de contexto
        ├── _handoff.md                # Transferencia
        └── rules/

{workspace}/.antigravity/              # WORKSPACE LOCAL
├── catalogo.yml                       # Índice local (opcional)
├── conocimiento/
│   ├── dominio.md                     # Conocimiento del proyecto
│   └── indice_corpus.md
└── diagnosticos/
```

## Pasos de Ejecución

### Para "ver"
// turbo
```bash
case "$1" in
  global)    ls -la ~/.gemini/user/ 2>/dev/null || echo "No existe" ;;
  workspace) ls -la .antigravity/conocimiento/ 2>/dev/null || echo "No existe" ;;
  sesion)    ls -la "$HOME/.gemini/antigravity/sesiones/"*/ 2>/dev/null | head -20 ;;
esac
```

### Para "agregar"
// turbo
```bash
NIVEL=$1
ARCHIVO=$2
case "$NIVEL" in
  global)    cp "$ARCHIVO" ~/.gemini/user/ && echo "✅ Agregado a global" ;;
  workspace) mkdir -p .antigravity/conocimiento && cp "$ARCHIVO" .antigravity/conocimiento/ && echo "✅ Agregado a workspace" ;;
  sesion)    
    SESION_ID=$3
    DEST="$HOME/.gemini/antigravity/sesiones/$SESION_ID"
    if [ -d "$DEST" ]; then
      cp "$ARCHIVO" "$DEST/" && echo "✅ Agregado a sesión $SESION_ID"
    else
      echo "❌ Sesión no encontrada: $SESION_ID"
    fi
    ;;
esac
```

### Para "limpiar"
1. Listar archivos de sesión
2. Confirmar eliminación
3. Preservar `_handoff.md` si existe

// turbo
```bash
SESSION_ID=$1
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$SESSION_ID"
if [ -d "$SESSION_DIR" ]; then
   echo "📋 Archivos en sesión $SESSION_ID:"
   ls -la "$SESSION_DIR"
   echo ""
   echo "⚠️ Se preservará _handoff.md"
fi
```


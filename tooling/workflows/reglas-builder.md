---
_manifest:
  urn: "urn:tooling:koda:workflows:reglas-builder:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Constructor de reglas Antigravity por diálogo guiado"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Constructor de Reglas

Diálogo guiado para crear reglas de Antigravity.

> **SSOT:** Límite de **12,000 caracteres** por archivo de regla.

## Uso

```
/reglas-builder
```

## Flujo

### Paso 1: Alcance
>
> 1. **Global** - Todas mis sesiones
> 2. **Workspace** - Solo este proyecto
> 3. **Sesión** - Solo esta sesión

### Paso 2: Categoría
>
> 1. Estilo de código
> 2. Convención de nombres
> 3. Comportamiento del agente
> 4. Preferencia de herramientas

### Paso 3: Modo de Activación
>
> 1. **Manual** - Activar con @mention
> 2. **Always_On** - Siempre aplicada
> 3. **Model_Decision** - El modelo decide
> 4. **Glob** - Por patrón de archivos (ej: `*.ts`)

### Paso 4: Redacción
>
> "Describe la regla en lenguaje natural"

### Paso 5: Refinamiento

```markdown
# Regla: [Nombre]
- Alcance: workspace
- Categoría: estilo
- Modo: always_on
- Descripción: [Texto]
- Ejemplo: [Código/Texto]
```

### Paso 6: Validación

// turbo

```bash
ARCHIVO=$1
if [ -f "$ARCHIVO" ]; then
   CHARS=$(wc -c < "$ARCHIVO")
   if [ "$CHARS" -gt 12000 ]; then
      echo "❌ ERROR: $CHARS caracteres excede límite de 12,000"
   else
      echo "✅ Válido: $CHARS caracteres"
   fi
fi
```

### Paso 7: Guardar

| Alcance   | Ubicación SSOT                                              |
| --------- | ----------------------------------------------------------- |
| Global    | `~/.gemini/GEMINI.md` (principal) o `~/.gemini/user/rules/` |
| Workspace | `{workspace}/.agent/rules/`                                 |
| Sesión    | `~/.gemini/antigravity/sesiones/{id}/rules/`                |

// turbo

```bash
ALCANCE=$1
NOMBRE=$2

case "$ALCANCE" in
  global)
    GEMINI_FILE="$HOME/.gemini/GEMINI.md"
    echo "📁 Regla global se agregará a: $GEMINI_FILE"
    echo ""
    echo "💡 Formato sugerido para agregar:"
    echo "---"
    echo "## $NOMBRE"
    echo "[Tu regla aquí]"
    echo "---"
    ;;
  workspace)
    mkdir -p .agent/rules
    DEST=".agent/rules/${NOMBRE}.md"
    echo "📁 Guardando en: $DEST"
    ;;
  sesion)
    SESSION_ID=$3
    mkdir -p "$HOME/.gemini/antigravity/sesiones/$SESSION_ID/rules"
    DEST="$HOME/.gemini/antigravity/sesiones/$SESSION_ID/rules/${NOMBRE}.md"
    echo "📁 Guardando en: $DEST"
    ;;
esac
echo "✅ Directorio de reglas listo"
```

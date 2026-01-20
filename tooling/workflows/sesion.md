---
_manifest:
  urn: "urn:tooling:koda:workflows:sesion:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Gestión unificada del ciclo de vida de sesiones Antigravity"
  compatible_agents: ["*"]
  trigger_states: [S-DISPATCHER]
  turbo: false
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Sesión

Comando central para iniciar, gestionar y cerrar sesiones de trabajo.

> **SSOT:** Las sesiones se almacenan globalmente en `~/.gemini/antigravity/sesiones/` para persistencia cross-workspace.

## Uso
```
/sesion [iniciar | cerrar | estado | catalogo]
```

---

## 🚀 /sesion iniciar

### Opciones

1. **Nueva Tarea (Desde Cero)**
   - Crea nueva entrada en catálogo global
   - Genera ID único

2. **Continuar Sesión (Handoff)**
   - Lista sesiones recientes via `/catalogo-sesiones`
   - Lee `_handoff.md` de sesión anterior
   - Carga contexto y artefactos

3. **Bifurcar Sesión (Branching)**
   - Usa `--rama {nombre}` para elegir rama específica
   - Busca `_handoff_{rama}.md`, fallback a `_handoff.md`

### Pasos: Nueva Tarea
// turbo
```bash
SESSION_BASE="$HOME/.gemini/antigravity/sesiones"
SESSION_ID="sesion-$(date +%Y%m%d-%H%M%S)"
SESSION_DIR="$SESSION_BASE/$SESSION_ID"

mkdir -p "$SESSION_DIR"
echo "✅ Nueva sesión creada: $SESSION_ID"
echo "📁 Ruta: $SESSION_DIR"
echo "💡 Usa skill context-manager para snapshots"
```

> **Nota:** La skill `context-manager` gestiona contexto. No se crea `_contexto.md`.

### Pasos: Continuar/Bifurcar
// turbo
```bash
ID=$1
RAMA=${2:-""}
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$ID"

if [ -d "$SESSION_DIR" ]; then
   if [ -n "$RAMA" ] && [ -f "$SESSION_DIR/_handoff_${RAMA}.md" ]; then
      echo "✅ Cargando rama: $RAMA"
      cat "$SESSION_DIR/_handoff_${RAMA}.md"
   elif [ -f "$SESSION_DIR/_handoff.md" ]; then
      echo "✅ Cargando handoff principal"
      cat "$SESSION_DIR/_handoff.md"
   else
      echo "⚠️ No hay handoff disponible"
   fi
else
   echo "❌ No existe sesión $ID"
   echo "📂 Sesiones disponibles:"
   ls -1 "$HOME/.gemini/antigravity/sesiones/" 2>/dev/null | tail -5
fi
```

---

## 🏁 /sesion cerrar

### Opciones de Cierre

| Opción              | Descripción                              | Cuándo usar              |
| ------------------- | ---------------------------------------- | ------------------------ |
| **Continuar (1→1)** | Guarda estado para seguir en otra sesión | Pausas, fin del día      |
| **Bifurcar (1→N)**  | Crea múltiples puntos de partida (ramas) | Varios enfoques, delegar |
| **Standby**         | Pausa sin crear handoff explícito        | Breve interrupción       |
| **Eliminar**        | Borra datos y handoffs de esta sesión    | Experimentación fallida  |

### Pasos: Continuar (1→1)

1. **Generar Resumen Ejecutivo** (máx 500 tokens):
   > "Resume el trabajo realizado: objetivo, logros, pendientes."

2. **Listar Artefactos Modificados**:
// turbo
```bash
find . -name "*.md" -newer /tmp/session_start 2>/dev/null | head -20
```

3. **Capturar Próximos Pasos**:
   > "Lista los próximos pasos como checklist Markdown."

4. **Crear Paquete Handoff** (via skill context-manager):
   > "Usa la skill context-manager para generar el handoff con esqueleto poblado."

// turbo
```bash
ID=$1
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$ID"
HANDOFF="$SESSION_DIR/_handoff.md"

if [ -d "$SESSION_DIR" ]; then
   echo "📦 Generando handoff para: $ID"
   echo "# Handoff: $ID" > "$HANDOFF"
   echo "" >> "$HANDOFF"
   echo "**Timestamp:** $(date -Iseconds)" >> "$HANDOFF"
   echo "**Workspace:** $(pwd)" >> "$HANDOFF"
   echo "" >> "$HANDOFF"
   echo "## Para Continuar" >> "$HANDOFF"
   echo "> Lee este handoff para restaurar contexto." >> "$HANDOFF"
   echo "" >> "$HANDOFF"
   echo "## Conocimiento Usado (Formato Esqueleto)" >> "$HANDOFF"
   echo "[Poblar con esqueleto de archivos consultados]" >> "$HANDOFF"
   echo "" >> "$HANDOFF"
   echo "## Próximos Pasos" >> "$HANDOFF"
   echo "- [ ] [Paso 1]" >> "$HANDOFF"
   echo "✅ Handoff creado: $HANDOFF"
else
   echo "❌ Sesión no encontrada: $ID"
fi
```

5. **Actualizar Catálogo**:
   - Ejecutar `/catalogo-sesiones actualizar`

### Pasos: Bifurcar (1→N)

1. Definir ramas y nombres
2. Generar `_handoff_{rama}.md` para cada una:
// turbo
```bash
ID=$1
RAMA=$2
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$ID"
HANDOFF="$SESSION_DIR/_handoff_${RAMA}.md"

if [ -d "$SESSION_DIR" ]; then
   echo "# Handoff Rama: $RAMA" > "$HANDOFF"
   echo "Parent: $ID" >> "$HANDOFF"
   echo "Timestamp: $(date -Iseconds)" >> "$HANDOFF"
   echo "✅ Rama creada: $RAMA"
else
   echo "❌ Sesión no encontrada: $ID"
fi
```

3. Actualizar catálogo: `estado: cerrada`, `siguientes: [rama-a, rama-b]`

### Pasos: Eliminar ⚠️

**Advertencia:** Esta acción es irreversible.

1. **Confirmar ID de sesión a eliminar**:
   > "¿Confirmas eliminar la sesión `{id}`? Esto borrará todos los handoffs y contexto."

2. **Ejecutar eliminación**:
// turbo
```bash
ID=$1
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$ID"

if [ -d "$SESSION_DIR" ]; then
   echo "📋 Contenido a eliminar:"
   ls -la "$SESSION_DIR"
   echo ""
   echo "⚠️ Esperando confirmación del usuario..."
fi
```

3. **Confirmar y borrar** (requiere aprobación explícita):
```bash
ID=$1
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$ID"

if [ -d "$SESSION_DIR" ]; then
   rm -rf "$SESSION_DIR"
   echo "🗑️ Sesión eliminada: $ID"
   # Actualizar catálogo
   CATALOGO="$HOME/.gemini/antigravity/sesiones/catalogo.yml"
   if [ -f "$CATALOGO" ]; then
      # Marcar como eliminada en catálogo (no borrar entrada para auditoría)
      sed -i '' "s/id: \"$ID\"/id: \"$ID\"\n    estado: \"eliminada\"/" "$CATALOGO" 2>/dev/null || true
   fi
else
   echo "❌ Sesión no encontrada: $ID"
fi
```

---

## 📊 /sesion estado

Muestra información de la sesión activa.

// turbo
```bash
SESSION_BASE="$HOME/.gemini/antigravity/sesiones"
echo "📂 Sesiones en: $SESSION_BASE"
echo ""
echo "🕐 Últimas 5 sesiones:"
ls -lt "$SESSION_BASE" 2>/dev/null | head -6
echo ""
echo "📊 Espacio usado:"
du -sh "$SESSION_BASE" 2>/dev/null
```

---

## 📂 /sesion catalogo

Alias para `/catalogo-sesiones`. Muestra árbol de sesiones.

// turbo
```bash
CATALOGO="$HOME/.gemini/antigravity/sesiones/catalogo.yml"
if [ -f "$CATALOGO" ]; then
   cat "$CATALOGO"
else
   echo "📋 No existe catálogo. Listando sesiones:"
   ls -1 "$HOME/.gemini/antigravity/sesiones/" 2>/dev/null
fi
```

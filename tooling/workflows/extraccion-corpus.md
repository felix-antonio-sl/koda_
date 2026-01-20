---
_manifest:
  urn: "urn:tooling:koda:workflows:extraccion-corpus:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Extracción recursiva de corpus extensos con esqueleto semántico"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Extracción de Corpus

Para procesar documentos extensos sin saturar contexto.

> **SSOT:** Artefactos de extracción se guardan en sesión global `~/.gemini/antigravity/sesiones/{id}/`

## Patrón
**Esqueleto → Búsqueda → Síntesis → Refinamiento**

## Fases

### Fase 0: Esqueleto Semántico
1. **Escaneo estructural:** Lista headings/secciones
2. **Muestreo:** Lee primeros 2 párrafos de cada sección
3. **Análisis:** Identifica conceptos, entidades, relaciones
4. **Guardar:** Integra en `_snapshot.md` activo (si existe) o crea nuevo

> **Integración:** El esqueleto generado se incorpora al `_snapshot.md` activo de la sesión.
> Usa skill `context-manager` para gestionar snapshots.

```markdown
# Esqueleto: [Nombre]

## Estructura
- Sección 1: Título (líneas 1-100)

## Conceptos Clave
- Concepto A: definición breve

## Secciones Relevantes
- Sección 2.3: Alta relevancia
```

// turbo
```bash
SESSION_ID=$1
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$SESSION_ID"
if [ -d "$SESSION_DIR" ]; then
   echo "📁 Esqueleto se guardará en: $SESSION_DIR/_esqueleto.md"
else
   echo "❌ Sesión no encontrada: $SESSION_ID"
   echo "💡 Crea una sesión primero con /sesion iniciar"
fi
```

### Fase 1: Búsqueda Dirigida
// turbo
```bash
TERMINO=$1
DOCUMENTO=$2
grep -n "$TERMINO" "$DOCUMENTO" | head -20
```

### Fase 2: Muestreo Selectivo
> "Lee las líneas {inicio}-{fin}"

Guardar en `~/.gemini/antigravity/sesiones/{id}/_extractos.md`

// turbo
```bash
SESSION_ID=$1
SESSION_DIR="$HOME/.gemini/antigravity/sesiones/$SESSION_ID"
EXTRACTOS="$SESSION_DIR/_extractos.md"
if [ -d "$SESSION_DIR" ]; then
   echo "📁 Extractos se guardarán en: $EXTRACTOS"
   touch "$EXTRACTOS"
fi
```

### Fase 3: Síntesis Iterativa
> "Resume cada fragmento en 1-2 oraciones"

### Fase 4: Validación
> "Verifica contra fuente original. Marca incertidumbres con [?]"


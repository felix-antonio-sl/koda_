---
_manifest:
  urn: "urn:tooling:koda:workflows:diagnostico-ag:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Análisis de diagnóstico Antigravity con recomendaciones"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Diagnóstico Antigravity

Analiza el archivo de diagnóstico y genera recomendaciones accionables.

> **SSOT:** Reportes se guardan globalmente en `~/.gemini/antigravity/diagnosticos/`

## Ruta por Defecto
`~/Downloads/Antigravity-diagnostics.txt`

## Pasos

### 1. Obtener Diagnóstico
> "Ejecuta en VS Code: `Antigravity: Download Antigravity Diagnostics`"

### 2. Verificar Archivo
// turbo
```bash
DIAG=~/Downloads/Antigravity-diagnostics.txt
if [ -f "$DIAG" ]; then
  echo "✅ Diagnóstico encontrado"
  timeout 5s wc -l "$DIAG" || echo "Archivo muy grande, procesando muestra..."
else
  echo "❌ No encontrado. Alternativas:"
  ls -t ~/Downloads/Antigravity* 2>/dev/null | head -3
fi
```

### 3. Parsear Patrones
| Patrón                | Severidad | Workflow             |
| --------------------- | --------- | -------------------- |
| Checkpoint truncated  | 🔴         | /higiene-antigravity |
| 429 Too Many Requests | 🔴         | /quota-status        |
| CDP session failed    | 🟡         | Reiniciar VS Code    |
| VERY LONG TASK        | 🟡         | Cerrar tabs          |

### 4. Generar Reporte
// turbo
```bash
DIAG="$HOME/Downloads/Antigravity-diagnostics.txt"
DIAG_DIR="$HOME/.gemini/antigravity/diagnosticos"
mkdir -p "$DIAG_DIR"
REPORTE="$DIAG_DIR/$(date +%Y-%m-%d_%H%M)_reporte.md"

if [ -f "$DIAG" ]; then
  # Grep directo sobre head - sin variable intermedia
  E429=$(head -1000 "$DIAG" | grep -c "429" 2>/dev/null || echo "0")
  TRUNC=$(head -1000 "$DIAG" | grep -c "truncated" 2>/dev/null || echo "0")
  CDP=$(head -1000 "$DIAG" | grep -c "CDP session" 2>/dev/null || echo "0")
  LONG=$(head -1000 "$DIAG" | grep -c "VERY LONG TASK" 2>/dev/null || echo "0")
  
  cat > "$REPORTE" << EOF
# Reporte de Diagnóstico Antigravity
**Fecha:** $(date -Iseconds)
**Muestra:** Primeras 2000 líneas del diagnóstico

## Patrones Detectados
| Patrón                | Conteo | Severidad | Acción               |
| :-------------------- | :----- | :-------- | :------------------- |
| 429 Too Many Requests | $E429  | 🔴         | /quota-status        |
| Checkpoint truncated  | $TRUNC | 🔴         | /higiene-antigravity |
| CDP session failed    | $CDP   | 🟡         | Reiniciar VS Code    |
| VERY LONG TASK        | $LONG  | 🟡         | Cerrar tabs          |

## Recomendaciones
EOF

  [ "$E429" -gt 5 ] && echo "- 🔴 **CRÍTICO**: Ejecutar \`/quota-status\` (Quota agotada)" >> "$REPORTE"
  [ "$TRUNC" -gt 10 ] && echo "- 🔴 **CRÍTICO**: Ejecutar \`/higiene-antigravity\` (Contexto saturado)" >> "$REPORTE"
  [ "$CDP" -gt 0 ] && echo "- 🟡 Reiniciar VS Code por errores CDP" >> "$REPORTE"
  [ "$LONG" -gt 0 ] && echo "- 🟡 Cerrar tabs innecesarias" >> "$REPORTE"
  
  echo ""
  echo "📁 Reporte: $REPORTE"
  cat "$REPORTE"
else
  echo "❌ No se encontró archivo de diagnóstico"
fi
```

### 5. Limpieza de Artefactos Huérfanos
> **Delegado a:** `/higiene-antigravity` para evitar duplicación de código.
> Ejecuta: `/higiene-antigravity` si se detecta saturación.


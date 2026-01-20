---
_manifest:
  urn: "urn:tooling:koda:workflows:salud-ag:1.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Meta-workflow de diagnóstico integral del entorno Antigravity"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Salud Antigravity

Meta-workflow que ejecuta un chequeo completo del entorno Antigravity.

> **SSOT:** Integra `/diagnostico-ag`, `/higiene-antigravity` y `/quota-status`

## Uso

```
/salud-ag [rapido | completo | reporte]
```

---

## ⚡ /salud-ag rapido

Chequeo rápido de 30 segundos. Ideal para inicio de sesión.

// turbo

```bash
echo "🏥 SALUD ANTIGRAVITY - Chequeo Rápido"
echo "======================================"
BRAIN_COUNT=$(ls "$HOME/.gemini/antigravity/brain" 2>/dev/null | wc -l | tr -d ' ')
echo "🧠 Brain: $BRAIN_COUNT sesiones"
DIAG="$HOME/Downloads/Antigravity-diagnostics.txt"
if [ -f "$DIAG" ]; then
   E429=$(head -1000 "$DIAG" | grep -c "429" 2>/dev/null || echo "0")
   TRUNC=$(head -1000 "$DIAG" | grep -c "truncated" 2>/dev/null || echo "0")
   echo "💳 Errores 429: $E429 | Truncados: $TRUNC"
else
   echo "💳 Sin diagnóstico reciente"
fi
[ "$BRAIN_COUNT" -gt 50 ] && echo "⚠️ Brain saturado" || echo "✅ OK"
```

---

## 🔬 /salud-ag completo

Chequeo profundo consolidado.

// turbo
```bash
echo "🔬 SALUD ANTIGRAVITY - Chequeo Completo"
echo "========================================"
DIAG="$HOME/Downloads/Antigravity-diagnostics.txt"
SCORE=100

# 1. Diagnóstico
echo "📋 Diagnóstico:"
if [ -f "$DIAG" ]; then
   echo "   ✅ Encontrado ($(wc -l < "$DIAG" | tr -d ' ') líneas)"
   E429=$(head -1000 "$DIAG" | grep -c "429" 2>/dev/null || echo "0")
   TRUNC=$(head -1000 "$DIAG" | grep -c "truncated" 2>/dev/null || echo "0")
   [ "$E429" -gt 5 ] && SCORE=$((SCORE - 30))
   [ "$TRUNC" -gt 10 ] && SCORE=$((SCORE - 20))
else
   echo "   ⚠️ No encontrado"; E429=0; TRUNC=0
fi

# 2. Brain
BRAIN=$(ls "$HOME/.gemini/antigravity/brain" 2>/dev/null | wc -l | tr -d ' ')
echo "🧠 Brain: $BRAIN sesiones"
[ "$BRAIN" -gt 50 ] && SCORE=$((SCORE - 20))

# 3. Métricas
echo "💳 Errores 429: $E429 | Truncados: $TRUNC"

# 4. Score
echo "========================================"
echo "🎯 Score: $SCORE/100"
if [ "$SCORE" -ge 80 ]; then echo "✅ EXCELENTE"
elif [ "$SCORE" -ge 60 ]; then echo "🟡 ACEPTABLE"
else echo "🔴 REQUIERE ATENCIÓN"; fi
```

---

---

## 📄 /salud-ag reporte

Genera un reporte Markdown persistente.

// turbo
```bash
REPORTE_DIR="$HOME/.gemini/antigravity/diagnosticos"
mkdir -p "$REPORTE_DIR"
REPORTE="$REPORTE_DIR/salud_$(date +%Y-%m-%d_%H%M).md"
BRAIN=$(ls "$HOME/.gemini/antigravity/brain" 2>/dev/null | wc -l | tr -d ' ')
DIAG="$HOME/Downloads/Antigravity-diagnostics.txt"
E429=$([ -f "$DIAG" ] && head -1000 "$DIAG" | grep -c "429" 2>/dev/null || echo "0")

cat > "$REPORTE" << EOF
# Reporte de Salud Antigravity
**Fecha:** $(date -Iseconds)

## Métricas
| Componente     | Valor  |
| :------------- | :----- |
| Brain Sessions | $BRAIN |
| Errores 429    | $E429  |

## Recomendaciones
- Ejecutar \`/higiene-antigravity\` si Brain > 50
- Revisar \`/quota-status\` si hay errores 429
EOF

echo "📄 Reporte: $REPORTE"
cat "$REPORTE"
```

---

## 🔗 Workflows Integrados

| Workflow               | Función en /salud-ag      |
| :--------------------- | :------------------------ |
| `/diagnostico-ag`      | Análisis de logs de error |
| `/higiene-antigravity` | Limpieza de artefactos    |
| `/quota-status`        | Estado de cuota API       |
| `/sesion estado`       | Sesiones activas          |

---

## 📅 Uso Recomendado

| Frecuencia  | Comando              | Cuándo                          |
| :---------- | :------------------- | :------------------------------ |
| **Diario**  | `/salud-ag rapido`   | Al iniciar sesión de trabajo    |
| **Semanal** | `/salud-ag completo` | Mantenimiento preventivo        |
| **Mensual** | `/salud-ag reporte`  | Documentación de estado         |
| **Ad-hoc**  | `/salud-ag completo` | Cuando notes lentitud o errores |

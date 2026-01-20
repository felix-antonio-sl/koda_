---
_manifest:
  urn: "urn:tooling:koda:workflows:quota-status:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Estado de quota y próxima renovación (Cockpit + API + Inferencia)"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Estado de Quota

Informa el uso de quota mediante múltiples métodos.

## Métodos

### 1. Antigravity Cockpit (Recomendado)
- Presiona `Ctrl/Cmd+Shift+Q`
- O revisa la barra de estado
- Muestra quota real, countdown y reset exacto

### 2. API Local (Experimental)
// turbo
```bash
PID=$(pgrep -f "antigravity" | head -1)
if [ -n "$PID" ]; then
   PORT=$(lsof -p $PID -i -P 2>/dev/null | grep LISTEN | awk '{print $9}' | cut -d: -f2 | head -1)
   if [ -n "$PORT" ]; then
      echo "📡 Antigravity LS en puerto $PORT"
   fi
else
   echo "❌ Proceso Antigravity no detectado"
fi
```

### 3. Inferencia (Fallback)
// turbo
```bash
DIAG=~/Downloads/Antigravity-diagnostics.txt
if [ -f "$DIAG" ]; then
  COUNT=$(grep -c "429 Too Many Requests" "$DIAG" 2>/dev/null)
  echo "📊 Errores 429: $COUNT"
  if [ "$COUNT" -gt 0 ]; then
     echo "💡 Última hora: quota posiblemente agotada"
  else
     echo "✅ Quota saludable"
  fi
fi
```

## Renovación Estimada (SSOT)

| Plan                                                  | Quota         | Frecuencia Renovación |
| ----------------------------------------------------- | ------------- | --------------------- |
| **Google AI Ultra / Workspace AI Ultra for Business** | Más generosa  | Cada 5 horas          |
| **Google AI Pro**                                     | Alta          | Cada 5 horas          |
| **Sin plan Google AI**                                | Significativa | Semanal               |

### Notas
- Los rate limits se determinan principalmente por capacidad y prevención de abuso.
- Los límites correlacionan con la cantidad de trabajo del agente.
- **No soportado:** Bring-your-own-key, bring-your-own-endpoint.


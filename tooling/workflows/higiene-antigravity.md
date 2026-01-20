---
_manifest:
  urn: "urn:tooling:koda:workflows:higiene-antigravity:2.0.0"
  type: workflow
  federation:
    visibility: public
    license: "CC-BY-4.0"

metadata:
  description: "Mantenimiento preventivo del entorno Antigravity"
  compatible_agents: ["*"]
  turbo: true
  ssot_ref: "manual_ag_fx_v2.md"
---

# Workflow: Higiene Antigravity

Ejecutar cuando notes:
- Truncamiento de contexto
- Lentitud
- Errores de escritura

## Pasos

### 1. Diagnóstico Rápido
// turbo
```bash
du -sh ~/.gemini/antigravity/brain/*/
```

### 2. Limpieza de Contexto
Si detectas saturación:
> "Saturación detectada. Ejecuta `/sesion cerrar` para guardar y reiniciar."

### 3. Referencias Cruzadas
- **Saturación:** `/sesion cerrar`
- **Errores 429:** `/quota-status`
- **Diagnóstico Profundo:** `/diagnostico-ag`

### 4. Reinicio Navegador (Errores CDP)
1. Cierra tabs de Antigravity
2. Reinicia VS Code

### 5. Limpieza de Artefactos Huérfanos
// turbo
```bash
find ~/.gemini/antigravity/brain/ -name "*.md" -mtime +7 | head -10
```

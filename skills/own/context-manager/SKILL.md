---
name: context-manager
description: Gestión de contexto para sesiones largas. Usa cuando el contexto se satura, necesitas hacer transición entre sesiones, o el usuario pide "snapshot" o "handoff".
---

# Context Manager

Skill para optimizar la ventana de contexto y mejorar transiciones entre sesiones.

## Cuándo Usar

- Sesión > 30 minutos
- Notas que el agente repite u olvida información
- Usuario pide "snapshot", "guardar contexto" o "handoff"
- Vas a cerrar sesión con `/sesion cerrar`
- Contexto saturado (>80% estimado)

## Comandos

### 1. Snapshot (Captura de Estado)

Genera `_snapshot.md` con esqueleto poblado de conocimiento.

**Trigger:** Usuario dice "snapshot" o "guarda el contexto"

**Acción:**
1. Identificar archivos consultados durante la sesión
2. Construir esqueleto semántico con contenido relevante
3. Guardar en `~/.gemini/antigravity/sesiones/{id}/_snapshot_{timestamp}.md`

### 2. Handoff (Transferencia)

Consolida snapshots en paquete de transferencia.

**Trigger:** `/sesion cerrar` o usuario dice "prepara handoff"

**Acción:**
1. Recopilar todos los snapshots de la sesión
2. Consolidar en `_handoff.md`
3. Incluir esqueleto poblado, decisiones, próximos pasos

### 3. Restore (Restauración)

Carga contexto de sesión anterior.

**Trigger:** `/sesion iniciar --continuar {id}` o usuario dice "continúa sesión X"

**Acción:**
1. Leer `_handoff.md` de la sesión
2. Cargar archivos referenciados en esqueleto
3. Restaurar estado mental

## Templates

### Snapshot
Ver `templates/snapshot.md`

### Handoff
Ver `templates/handoff.md`

## Integración con KODA

Si estás operando como agente KODA (via `/encarnacion`):

- `CM-CONTEXT-MANAGER` monitorea saturación
- Al llegar a S-END, genera handoff automáticamente
- Al entrar a S-DISPATCHER, carga handoff si existe

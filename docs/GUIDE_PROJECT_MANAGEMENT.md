# Guía de Gestión de Proyectos y Tareas KODA

> **Para:** Felix (Maintainer principal)  
> **Propósito:** Metodología y flujos de trabajo para gestionar el mantenimiento y evolución del framework KODA.

---

## Índice

1. [Visión General](#1-visión-general)
2. [Herramientas Disponibles](#2-herramientas-disponibles)
3. [Sistema de Labels](#3-sistema-de-labels)
4. [Flujo de Trabajo de Issues](#4-flujo-de-trabajo-de-issues)
5. [GitHub Projects (Kanban)](#5-github-projects-kanban)
6. [Ciclo de Vida de una Tarea](#6-ciclo-de-vida-de-una-tarea)
7. [Automatizaciones](#7-automatizaciones)
8. [Escenarios Comunes](#8-escenarios-comunes)
9. [Comandos Útiles](#9-comandos-útiles)

---

## 1. Visión General

### ¿Por qué necesitamos esto?

KODA ha crecido: 10 guías core, 7 agentes, federation con 6 namespaces, scripts CLI, CI/CD. Sin un sistema de gestión, las tareas se pierden en chats y notas mentales.

### Principios

| Principio | Descripción |
|-----------|-------------|
| **Todo es un Issue** | Cualquier trabajo (bug, mejora, mantenimiento) se trackea como issue |
| **Labels son metadata** | Clasifican por tipo, scope, prioridad |
| **Board es visualización** | GitHub Project muestra el estado de todo |
| **CI es vigilante** | Detecta drift y crea issues automáticamente |

### Stack de Gestión

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Project (Board)                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐│
│  │ Backlog  │ │  Ready   │ │In Progress│ │       Done      ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────┴───────────────────────────────┐
│                      GitHub Issues                           │
│  • Templates (maintenance, enhancement, bug)                 │
│  • Labels (type, scope, priority, status)                   │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ crea issues automáticos
┌─────────────────────────────┴───────────────────────────────┐
│                      GitHub Actions                          │
│  • koda-validate.yml (PR gate)                              │
│  • koda-audit.yml (scheduled + manual)                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Herramientas Disponibles

### Archivos de configuración

| Archivo | Propósito |
|---------|-----------|
| `.github/labels.yml` | Definición de labels (referencia) |
| `.github/ISSUE_TEMPLATE/config.yml` | Config de templates |
| `.github/ISSUE_TEMPLATE/maintenance.yml` | Template: tareas de mantenimiento |
| `.github/ISSUE_TEMPLATE/enhancement.yml` | Template: mejoras |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Template: bugs |
| `.github/workflows/koda-validate.yml` | CI: validación en PRs |
| `.github/workflows/koda-audit.yml` | CI: auditoría semanal |
| `scripts/koda-audit.sh` | Script de auditoría local |

### Herramientas CLI

```bash
# Validación local
./scripts/koda validate

# Health check de federation
./scripts/koda health --full

# Auditoría completa
./scripts/koda-audit.sh
```

---

## 3. Sistema de Labels

### Por Tipo (¿Qué es?)

| Label | Color | Uso |
|-------|-------|-----|
| `type:maintenance` | 🟢 Verde | Sync, audit, updates |
| `type:enhancement` | 🔵 Azul | Nueva funcionalidad |
| `type:bug` | 🔴 Rojo | Error o inconsistencia |
| `type:docs` | 🔵 Azul oscuro | Solo documentación |
| `type:ci` | 🟡 Amarillo | CI/CD |

### Por Scope (¿Dónde?)

| Label | Afecta |
|-------|--------|
| `scope:guides` | `knowledge/core/` |
| `scope:agents` | `agents/` |
| `scope:schemas` | `schemas/` |
| `scope:scripts` | `scripts/` |
| `scope:federation` | `registry/`, `.knowledge-resolver.yml` |

### Por Prioridad (¿Cuándo?)

| Label | Significado | Acción |
|-------|-------------|--------|
| `priority:P0` | 🔴 Crítico | Bloquea releases, resolver YA |
| `priority:P1` | 🟠 Alto | Este sprint |
| `priority:P2` | 🟡 Medio | Cuando haya tiempo |
| `priority:P3` | 🔵 Bajo | Nice to have |

### Por Estado (¿Cómo va?)

| Label | Significado |
|-------|-------------|
| `status:blocked` | Esperando dependencia |
| `status:needs-info` | Falta información |
| `status:ready` | Listo para trabajar |

### Automáticos

| Label | Puesto por |
|-------|------------|
| `auto:audit` | Workflow `koda-audit.yml` |

---

## 4. Flujo de Trabajo de Issues

### Crear un Issue

1. Ve a **Issues** → **New Issue**
2. Selecciona template:
   - 🔧 **Maintenance Task** → para sync, updates, migraciones
   - ✨ **Enhancement** → para mejoras y nuevas features
   - 🐛 **Bug Report** → para errores
3. Llena los campos del formulario
4. Agrega labels adicionales si faltan (el template pone algunos automáticamente)

### Estructura de un buen Issue

```markdown
## Título: [MAINT] Actualizar LLM_Parsing_Instructions en agentes

### Scope: agents

### Priority: P1 - High

### Description
Los 7 agentes en `agents/` tienen LLM_Parsing_Instructions desactualizado.
Falta XRef/XRef_Required en el LEXICON.

### Affected Files
- agents/koda-smith/agent_koda_smith.yaml
- agents/koda-transformer/agent_koda_transformer.yaml

### Acceptance Criteria
- [ ] Todos los agentes tienen LEXICON actualizado
- [ ] `koda-audit.sh` pasa sin drift
- [ ] PR revisado y mergeado
```

---

## 5. GitHub Projects (Kanban)

### Crear el Project (una sola vez)

1. Ve a tu perfil o al repo → **Projects** → **New Project**
2. Selecciona **Board** (Kanban)
3. Nombre: `KODA Maintenance`
4. Crea columnas:
   - **Backlog** → Issues nuevos
   - **Ready** → Priorizados para trabajar
   - **In Progress** → En trabajo activo
   - **Review** → En PR esperando merge
   - **Done** → Completado

### Vincular Issues al Project

- Al crear un issue, en el panel derecho selecciona **Projects** → `KODA Maintenance`
- El issue aparecerá en la columna default (Backlog)

### Mover entre columnas

- Drag & drop en el board
- O desde el issue, cambiar el campo "Status" del project

### Vista de Roadmap (opcional)

1. En el Project, agrega una vista **Roadmap**
2. Agrupa por **Milestone** (v1.1.0, v1.2.0, etc.)
3. Útil para planificar releases

---

## 6. Ciclo de Vida de una Tarea

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. IDENTIFICACIÓN                                              │
│     • Audit detecta drift → crea issue automático               │
│     • Tú identificas mejora → creas issue manual                │
│     • Usuario reporta bug → issue con template                  │
│                          ↓                                      │
│  2. TRIAGE (Backlog)                                            │
│     • Revisar descripción                                       │
│     • Asignar labels: type, scope, priority                     │
│                          ↓                                      │
│  3. PRIORIZACIÓN (Ready)                                        │
│     • Mover a "Ready" cuando decides trabajarlo                 │
│     • Considerar dependencias                                   │
│                          ↓                                      │
│  4. EJECUCIÓN (In Progress)                                     │
│     • Crear branch: feat/issue-123-descripcion                  │
│     • Hacer cambios                                             │
│     • Commit con referencia: "feat(scope): desc. Fixes #123"    │
│                          ↓                                      │
│  5. REVISIÓN (Review)                                           │
│     • Crear PR                                                  │
│     • CI valida automáticamente                                 │
│     • Self-review o pedir review                                │
│                          ↓                                      │
│  6. MERGE (Done)                                                │
│     • Merge PR                                                  │
│     • Issue se cierra automáticamente (si usaste "Fixes #123")  │
│     • Issue se mueve a Done en el board                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Convención de Commits

```
<type>(<scope>): <descripción corta>

[cuerpo opcional]

[footer: Fixes #123]
```

**Ejemplos:**

```bash
git commit -m "feat(agents): add XRef to LLM_Parsing_Instructions. Fixes #42"
git commit -m "fix(guides): correct koda_ URL in federation guide"
git commit -m "chore(ci): add weekly audit workflow"
```

---

## 7. Automatizaciones

### Audit Semanal

**Qué hace:** Cada lunes a las 09:00 UTC, `koda-audit.yml` ejecuta `koda-audit.sh`.

**Si encuentra drift:**
1. Crea un issue con título "🔍 KODA Audit: Drift Detected"
2. Labels: `auto:audit`, `type:maintenance`, `priority:P1`
3. Body: reporte completo del audit

**Si ya existe un issue de audit abierto:**
- Agrega un comentario con el nuevo reporte (no crea duplicados)

**Trigger manual:**
- Ve a **Actions** → **KODA Audit** → **Run workflow**

### Validación en PRs

**Qué hace:** En cada PR que toca `knowledge/`, `agents/`, `catalog/`, etc.:
1. Valida sintaxis YAML
2. Verifica `.knowledge-resolver.yml`
3. Valida manifests de artefactos
4. Verifica integridad del catálogo
5. Chequea fallback URLs de federation

**Si falla:** El PR queda bloqueado hasta que se arregle.

---

## 8. Escenarios Comunes

### Escenario 1: El audit detectó drift

```
1. Recibes notificación de nuevo issue "KODA Audit: Drift Detected"
2. Abres el issue, lees el reporte
3. Identificas archivos afectados
4. Creas branch: git checkout -b fix/audit-drift-llm-instructions
5. Haces los cambios
6. Verificas local: ./scripts/koda-audit.sh
7. Commit: git commit -m "fix(agents): sync LLM_Parsing_Instructions. Fixes #XX"
8. Push y creas PR
9. CI valida, mergeas
10. Issue se cierra automático
```

### Escenario 2: Quieres agregar una nueva feature

```
1. Creas issue con template "Enhancement"
2. Lo agregas al Project, columna Backlog
3. Cuando decides trabajarlo, mueves a Ready
4. Creas branch: git checkout -b feat/nueva-feature
5. Desarrollas, commitseas
6. Push, PR, CI valida
7. Merge
8. Issue cierra
```

### Escenario 3: Revisión semanal de backlog

```
1. Abre el GitHub Project (board)
2. Revisa columna Backlog:
   - ¿Hay issues duplicados? → Cierra duplicados
   - ¿Hay issues obsoletos? → Cierra con comentario
   - ¿Hay issues listos para trabajar? → Mueve a Ready
3. Revisa columna In Progress:
   - ¿Hay algo bloqueado? → Agrega label status:blocked
   - ¿Hay algo abandonado? → Decide si continuar o mover a Backlog
4. Actualiza prioridades según necesidad
```

---

## 9. Comandos Útiles

### Git

```bash
# Crear branch para issue
git checkout -b feat/issue-123-descripcion

# Commit con referencia a issue
git commit -m "feat(scope): descripción. Fixes #123"

# Push y crear PR
git push -u origin feat/issue-123-descripcion
# Luego en GitHub: "Compare & pull request"
```

### KODA CLI

```bash
# Validar estructura del repo
./scripts/koda validate

# Health check completo
./scripts/koda health --full

# Audit local (antes de PR)
./scripts/koda-audit.sh

# Sincronizar namespace
./scripts/koda sync
```

### GitHub CLI (gh)

```bash
# Crear issue desde terminal
gh issue create --title "[MAINT] Descripción" --label "type:maintenance,priority:P1"

# Listar issues por label
gh issue list --label "type:maintenance"

# Cerrar issue
gh issue close 123 --comment "Resuelto en PR #456"

# Ver PRs pendientes
gh pr list

# Crear PR
gh pr create --title "feat(scope): descripción" --body "Fixes #123"
```

---

## Checklist de Setup Inicial

Si es la primera vez que usas este sistema:

- [ ] Crear labels en el repo (puedes usar `gh label create` con los valores de `.github/labels.yml`)
- [ ] Crear GitHub Project "KODA Maintenance" con columnas Backlog/Ready/In Progress/Review/Done
- [ ] Vincular el repo al Project
- [ ] Crear Milestones: v1.1.0, v1.2.0, etc.
- [ ] Poblar Backlog con issues iniciales
- [ ] Ejecutar `./scripts/koda-audit.sh` para ver estado actual

---

## Recursos

- [GitHub Issues Docs](https://docs.github.com/en/issues)
- [GitHub Projects Docs](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [KODA/Life Guide](../knowledge/core/guide_core_004_koda-life-master_koda.yml) - Sección de Git Management

---

*Última actualización: 2025-12-03*

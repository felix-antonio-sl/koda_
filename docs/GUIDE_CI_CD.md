# Guía de CI/CD para KODA

> **Para:** Cualquier humano que quiera entender qué pasa "detrás de escena" cuando haces push o creas un PR en KODA.

---

## Índice

1. [¿Qué es CI/CD?](#1-qué-es-cicd)
2. [CI/CD en el contexto de KODA](#2-cicd-en-el-contexto-de-koda)
3. [Anatomía de un Workflow](#3-anatomía-de-un-workflow)
4. [Workflow: koda-validate.yml](#4-workflow-koda-validateyml)
5. [Workflow: koda-audit.yml](#5-workflow-koda-audityml)
6. [Workflow: koda-sync.yml](#6-workflow-koda-syncyml)
7. [¿Qué pasa cuando hago push?](#7-qué-pasa-cuando-hago-push)
8. [¿Qué pasa cuando creo un PR?](#8-qué-pasa-cuando-creo-un-pr)
9. [Debugging: Cuando algo falla](#9-debugging-cuando-algo-falla)
10. [Glosario](#10-glosario)

---

## 1. ¿Qué es CI/CD?

### CI = Continuous Integration

**Integración Continua** significa que cada vez que alguien hace cambios al código, esos cambios se verifican automáticamente.

```
Tu código local → Push a GitHub → CI ejecuta pruebas → ✅ o ❌
```

**Beneficios:**
- Detecta errores temprano (antes de que lleguen a producción)
- Todos los cambios pasan por las mismas verificaciones
- No dependes de "acordarte" de ejecutar tests manualmente

### CD = Continuous Delivery/Deployment

**Entrega/Despliegue Continuo** significa que el código validado se puede desplegar automáticamente.

```
CI pasa ✅ → CD despliega → Tu cambio está en producción
```

**En KODA:** No tenemos CD tradicional (no hay servidor que desplegar), pero tenemos:
- Sincronización automática de timestamps
- Publicación de artefactos en GitHub

---

## 2. CI/CD en el contexto de KODA

### ¿Por qué KODA necesita CI/CD?

KODA es un **framework de conocimiento estructurado**. A diferencia de código tradicional que "compila o no compila", KODA tiene reglas más sutiles:

| Qué validar | Por qué importa |
|-------------|-----------------|
| **Sintaxis YAML** | Un YAML mal formado rompe la carga de artefactos |
| **Manifests presentes** | Sin `_manifest`, un artefacto no es federadle |
| **URNs resolubles** | Referencias a artefactos que no existen causan errores en agentes |
| **Catálogo sincronizado** | Si el catálogo dice que existe un archivo que no existe, la resolución falla |
| **LLM_Parsing_Instructions consistente** | Drift en las instrucciones causa comportamiento inconsistente en agentes |

### Nuestros Workflows

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Actions                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐  ┌─────────────────┐              │
│  │ koda-validate   │  │   koda-audit    │              │
│  │                 │  │                 │              │
│  │ • En cada PR    │  │ • Cada lunes    │              │
│  │ • En cada push  │  │ • Manual        │              │
│  │                 │  │                 │              │
│  │ GATE: Bloquea   │  │ VIGILANTE:      │              │
│  │ PRs rotos       │  │ Detecta drift   │              │
│  └─────────────────┘  └─────────────────┘              │
│                                                         │
│  ┌─────────────────┐                                   │
│  │   koda-sync     │                                   │
│  │                 │                                   │
│  │ • En cada push  │                                   │
│  │   a main        │                                   │
│  │                 │                                   │
│  │ SYNC: Actualiza │                                   │
│  │ timestamps      │                                   │
│  └─────────────────┘                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Anatomía de un Workflow

Un workflow de GitHub Actions es un archivo YAML en `.github/workflows/`. Veamos su estructura:

```yaml
# 1. NOMBRE - Aparece en la UI de GitHub
name: Mi Workflow

# 2. TRIGGERS - ¿Cuándo se ejecuta?
on:
  push:                    # Cuando haces push
    branches: [main]       # Solo a la rama main
    paths:                 # Solo si tocas estos archivos
      - 'knowledge/**'
  pull_request:            # Cuando creas/actualizas un PR
    branches: [main]
  schedule:                # En horarios fijos
    - cron: '0 9 * * 1'   # Lunes 9am UTC
  workflow_dispatch:       # Botón manual en la UI

# 3. JOBS - Las tareas a ejecutar
jobs:
  mi-job:                  # Nombre interno del job
    name: Mi Job Bonito    # Nombre que aparece en la UI
    runs-on: ubuntu-latest # Sistema operativo

    # 4. STEPS - Pasos secuenciales dentro del job
    steps:
      - name: Paso 1
        uses: actions/checkout@v4  # Acción predefinida

      - name: Paso 2
        run: |                     # Comandos bash
          echo "Hola mundo"
          ./mi-script.sh
```

### Conceptos clave

| Concepto | Qué es |
|----------|--------|
| **Workflow** | El archivo YAML completo |
| **Trigger** | Evento que dispara la ejecución |
| **Job** | Grupo de pasos que corren en la misma máquina |
| **Step** | Una tarea individual (correr script, usar action) |
| **Action** | Código reutilizable (ej: `actions/checkout@v4`) |
| **Runner** | La máquina virtual donde corre (ej: `ubuntu-latest`) |

---

## 4. Workflow: koda-validate.yml

### Propósito

**Gate de calidad**: Verificar que los cambios no rompan la estructura del framework.

### Cuándo se ejecuta

- **Push** a cualquier rama que toque: `knowledge/`, `agents/`, `schemas/`, `catalog/`, `.knowledge-resolver.yml`
- **Pull Request** hacia `main` que toque esos mismos archivos

### Qué hace (paso a paso)

```
┌─────────────────────────────────────────────────────────┐
│                 koda-validate.yml                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Checkout                                            │
│     └─ Descarga el código del repo                      │
│                                                         │
│  2. Setup Python                                        │
│     └─ Instala Python 3.11                              │
│                                                         │
│  3. Install dependencies                                │
│     └─ pip install pyyaml yamllint                      │
│                                                         │
│  4. Validate YAML syntax                                │
│     └─ yamllint sobre knowledge/, agents/, catalog/     │
│     └─ Si hay error de sintaxis → FALLA ❌              │
│                                                         │
│  5. Validate resolver configuration                     │
│     └─ Verifica que .knowledge-resolver.yml tenga:      │
│        • _meta.resolver_version                         │
│        • _meta.koda_compatibility                       │
│        • self.namespace                                 │
│     └─ Si falta algo → FALLA ❌                         │
│                                                         │
│  6. Validate artifact manifests                         │
│     └─ Para cada .yml en knowledge/ y agents/:          │
│        • ¿Tiene _manifest?                              │
│        • ¿Tiene _manifest.urn?                          │
│     └─ Si falta → FALLA ❌                              │
│                                                         │
│  7. Check federation health                             │
│     └─ Para cada namespace en resolver:                 │
│        • ¿Su fallback URL responde?                     │
│     └─ Si no responde → WARNING ⚠️ (no falla)          │
│                                                         │
│  8. Validate catalog consistency                        │
│     └─ Para cada entry en catalog:                      │
│        • ¿El archivo referenciado existe?               │
│     └─ Si no existe → FALLA ❌                          │
│                                                         │
│  9. Summary                                             │
│     └─ Imprime resultado final                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Ejemplo de output exitoso

```
🔍 Validating YAML syntax...
✅ YAML syntax valid
🔍 Validating .knowledge-resolver.yml...
✅ Resolver valid for namespace: koda
🔍 Validating artifact manifests...
✅ All artifact manifests valid
🔍 Checking fallback URL availability...
✅ koda: fallback reachable
✅ sanixai: fallback reachable
✅ Federation health check complete
🔍 Validating catalog...
✅ Catalog consistency valid
========================================
KODA Validation Complete
========================================
```

---

## 5. Workflow: koda-audit.yml

### Propósito

**Vigilante proactivo**: Detectar drift y problemas que no se detectan en validación básica.

### Cuándo se ejecuta

- **Schedule**: Cada lunes a las 09:00 UTC
- **Manual**: Desde Actions → KODA Audit → Run workflow

### Qué hace (paso a paso)

```
┌─────────────────────────────────────────────────────────┐
│                  koda-audit.yml                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Checkout                                            │
│     └─ Descarga el código                               │
│                                                         │
│  2. Make scripts executable                             │
│     └─ chmod +x scripts/koda scripts/koda-*.sh          │
│                                                         │
│  3. Run KODA Audit                                      │
│     └─ Ejecuta scripts/koda-audit.sh                    │
│     └─ Captura output en audit-report.txt               │
│     └─ Guarda exit code                                 │
│                                                         │
│  4. Upload Audit Report                                 │
│     └─ Sube audit-report.txt como artifact              │
│     └─ Disponible por 30 días                           │
│                                                         │
│  5. Create Issue on Drift (si exit code ≠ 0)            │
│     └─ ¿Ya existe issue abierto con label auto:audit?   │
│        • SÍ → Agrega comentario con nuevo reporte       │
│        • NO → Crea issue nuevo con:                     │
│          - Título: "🔍 KODA Audit: Drift Detected"      │
│          - Labels: auto:audit, type:maintenance, P1     │
│          - Body: reporte completo                       │
│                                                         │
│  6. Audit Summary                                       │
│     └─ exit 0 → "✅ KODA Audit passed"                  │
│     └─ exit 1 → "⚠️ KODA Audit found issues"           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### El script koda-audit.sh verifica

1. **LLM_Parsing_Instructions Consistency**
   - Usa `guide_core_001_koda-spec_koda.yml` como canónico
   - Compara fingerprint (hash de línea LEXICON) con todos los demás archivos
   - Si difiere → DRIFT

2. **Catalog Integrity**
   - Todos los archivos referenciados en el catálogo deben existir
   - Conteo de artefactos

3. **URN Resolution**
   - URNs referenciados en `knowledge/` y `agents/` deben estar en el catálogo

4. **Federation Health**
   - `.knowledge-resolver.yml` debe existir
   - `registry/namespaces.yml` debe existir

5. **Version Consistency**
   - Guías core deben tener campo `Version:`

---

## 6. Workflow: koda-sync.yml

### Propósito

**Sincronizador**: Mantener timestamps actualizados.

### Cuándo se ejecuta

- **Push** a `main`

### Qué hace

1. Actualiza `last_sync` en `.knowledge-resolver.yml`
2. Commit automático con los cambios

---

## 7. ¿Qué pasa cuando hago push?

### Escenario: Push a una rama (no main)

```
Tu máquina                     GitHub
    │                             │
    │  git push origin mi-rama    │
    │────────────────────────────▶│
    │                             │
    │                             │ ¿Tocaste knowledge/, agents/, etc?
    │                             │     │
    │                             │     ├─ NO → Nada pasa
    │                             │     │
    │                             │     └─ SÍ → koda-validate.yml
    │                             │              │
    │                             │              ├─ Checkout
    │                             │              ├─ Setup Python
    │                             │              ├─ Validate YAML
    │                             │              ├─ Validate resolver
    │                             │              ├─ Validate manifests
    │                             │              ├─ Check federation
    │                             │              └─ Validate catalog
    │                             │
    │  ◀──── Resultado ✅ o ❌ ───│
    │                             │
```

### Escenario: Push a main

```
Mismo flujo que arriba, PERO además:

    │                             │
    │                             │ koda-sync.yml
    │                             │     │
    │                             │     ├─ Actualiza last_sync
    │                             │     └─ Auto-commit
    │                             │
```

---

## 8. ¿Qué pasa cuando creo un PR?

```
Tu rama ────────────────────────────────────────▶ main
                        │
                        │ Pull Request creado
                        ▼
              ┌─────────────────────┐
              │  koda-validate.yml  │
              │                     │
              │  Ejecuta todas las  │
              │  validaciones       │
              └─────────┬───────────┘
                        │
           ┌────────────┴────────────┐
           │                         │
           ▼                         ▼
    ✅ All checks pass        ❌ Some checks failed
           │                         │
           ▼                         ▼
    ┌─────────────┐           ┌──────────────────┐
    │ PR mergeable │           │ PR blocked       │
    │              │           │                  │
    │ Botón verde  │           │ "Fix errors      │
    │ "Merge"      │           │  before merging" │
    └─────────────┘           └──────────────────┘
```

### En la UI de GitHub

1. Ve a tu PR
2. Abajo verás "Checks":
   ```
   ✅ KODA Validation - All checks passed
   ```
   o
   ```
   ❌ KODA Validation - Some checks failed
      → Click para ver detalles
   ```

---

## 9. Debugging: Cuando algo falla

### Ver logs detallados

1. Ve a **Actions** en el repo
2. Click en el workflow que falló
3. Click en el job (ej: "Validate KODA Artifacts")
4. Expande el step que falló

### Errores comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `Missing _manifest in file.yml` | Artefacto sin manifest | Agregar bloque `_manifest:` con URN |
| `YAML error in file.yml` | Sintaxis YAML inválida | Revisar indentación, comillas, caracteres especiales |
| `Catalog references non-existent file` | Archivo en catálogo no existe | Crear el archivo o quitar entrada del catálogo |
| `DRIFT: agents/...` | LLM_Parsing_Instructions diferente | Copiar LEXICON canónico de guide_core_001 |

### Validar localmente antes de push

```bash
# Validación rápida
./scripts/koda validate

# Auditoría completa
./scripts/koda-audit.sh

# Si todo pasa → push con confianza
```

---

## 10. Glosario

| Término | Definición |
|---------|------------|
| **CI** | Continuous Integration - verificación automática de cambios |
| **CD** | Continuous Delivery/Deployment - despliegue automático |
| **Workflow** | Archivo YAML que define qué ejecutar y cuándo |
| **Job** | Grupo de pasos que corren en una máquina |
| **Step** | Una tarea individual dentro de un job |
| **Action** | Código reutilizable (ej: `actions/checkout`) |
| **Runner** | Máquina virtual donde corren los jobs |
| **Trigger** | Evento que dispara un workflow |
| **Artifact** | Archivo generado por CI que se puede descargar |
| **Gate** | Verificación que debe pasar para mergear |
| **Drift** | Desviación de un estándar o estado esperado |

---

## Diagrama resumen

```
                    ┌─────────────────┐
                    │    Developer    │
                    └────────┬────────┘
                             │
                    git push / PR
                             │
                             ▼
┌────────────────────────────────────────────────────────────┐
│                        GitHub                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   Workflows                           │  │
│  │                                                       │  │
│  │   push/PR          schedule           push to main    │  │
│  │      │               │                     │          │  │
│  │      ▼               ▼                     ▼          │  │
│  │  validate.yml    audit.yml            sync.yml        │  │
│  │      │               │                     │          │  │
│  │      ▼               ▼                     ▼          │  │
│  │   ✅/❌          Report +             Auto-commit     │  │
│  │   Gate           Issue if drift                       │  │
│  │                                                       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    Issues                             │  │
│  │  • Manual (via templates)                             │  │
│  │  • Auto (via audit workflow)                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   Project Board                       │  │
│  │  Backlog → Ready → In Progress → Review → Done        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

*Última actualización: 2025-12-03*

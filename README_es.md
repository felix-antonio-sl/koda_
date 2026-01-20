# KODA Framework — Agentes Declarativos Orientados al Conocimiento

> **Versión Actual**: 2025-11-25  
> **Formato**: KODA-YAML (Knowledge-Oriented Declarative Architecture)  
> **Licencia**: CC-BY-4.0

*[English version](README.md)*

## Descripción General

Este corpus contiene los artefactos fundacionales para **Ingeniería de Agentes** usando el Framework KODA. Provee un framework completo y coherente para:

- **KODA/Spec** — Formato estructurado de conocimiento (YAML optimizado para RAG)
- **KODA/Agent** — Protocolo declarativo de definición de agentes
- **KODA/Hub** — Gestión federada de conocimiento
- **KODA/Life** — Gestión del ciclo de vida de agentes
- **KODA/Test** — Framework de testing de agentes

## Inicio Rápido

**¿Nuevo en el framework?** Comienza con la guía de inicio rápido:
```
knowledge/core/guide_core_000_quickstart_koda.yml → Construye tu primer agente en 30 minutos
```

## Estructura del Repositorio

```
KODA/
├── knowledge/               # Todos los artefactos de conocimiento
│   ├── core/               # Especificaciones del framework (10 guías)
│   │   └── guide_core_*.yml
│   └── domains/            # KBs específicas de dominio
├── agents/                 # Definiciones de agentes
├── schemas/                # JSON Schemas
├── catalog/                # Inventario de artefactos
├── registry/               # Registro de namespaces federados
├── scripts/                # Herramientas CLI
│   ├── koda              # Punto de entrada CLI
│   ├── koda-init.sh      # Inicializar nuevo repo
│   ├── koda-validate.sh  # Validar repositorio
│   ├── koda-add-artifact.sh  # Crear artefacto (interactivo)
│   └── koda-health.sh    # Health check de federación
├── templates/              # Plantillas de artefactos
│   ├── artifact.template.yml
│   └── agent.template.yml
├── .github/workflows/      # Automatización CI/CD
├── sources/                # Materiales fuente
└── staging/                # Trabajo en progreso (gitignored)
```

## Inventario de Artefactos

Todas las guías core ubicadas en `knowledge/core/`:

| # | Archivo | URN | Propósito |
|---|---------|-----|-----------|
| 000 | `guide_core_000_quickstart_koda.yml` | `urn:knowledge:koda:core:quickstart:1.0.0` | **Guía de inicio rápido (EMPIEZA AQUÍ)** |
| 001 | `guide_core_001_koda-spec_koda.yml` | `urn:knowledge:koda:core:spec:1.0.0` | Especificación del formato KODA/Spec (RAÍZ) |
| 002 | `guide_core_002_koda-transform_koda.yml` | `urn:knowledge:koda:core:transform:1.0.0` | Metodología de transformación KODA/Spec |
| 003 | `guide_core_003_koda-hub-federation_koda.yml` | `urn:knowledge:koda:core:hub-federation:1.0.0` | KODA Hub & Federation |
| 004 | `guide_core_004_koda-life-master_koda.yml` | `urn:knowledge:koda:core:life:1.0.0` | Gestión KODA/Life |
| 005 | `guide_core_005_koda-agent-spec_koda.yml` | `urn:knowledge:koda:core:agent:1.0.0` | Especificación del protocolo KODA/Agent |
| 006 | `guide_core_006_koda-agent-construct_koda.yml` | `urn:knowledge:koda:core:agent-construct:1.0.0` | Metodología de construcción KODA/Agent |
| 007 | `guide_core_007_koda-test-spec_koda.yml` | `urn:knowledge:koda:core:test:1.0.0` | Framework KODA/Test |
| 008 | `guide_core_008_schema-versioning_koda.yml` | `urn:knowledge:koda:core:schema-versioning:1.0.0` | Política de versionado de schemas |
| 009 | `guide_core_009_koda-tooling-spec_koda.yml` | `urn:knowledge:koda:core:tooling:1.0.0` | Especificación KODA/Tooling |

### Archivos de Schema

| Archivo | Propósito |
|---------|-----------|
| `schemas/koda-agent-schema-1.0.0.json` | JSON Schema para validación de agent.yaml |
| `schemas/koda-tooling-schema-1.0.0.json` | JSON Schema para artefactos de tooling |

## Grafo de Dependencias

```
quickstart (000) ─────────────────────────────────────────────────────────┐
    │ (punto de entrada)                                                  │
    ▼                                                                     │
koda-spec (001) ───────────────────────────────────────────────────────────┤
    │                                                                     │
    ├──► koda-transform (002)                                             │
    │                                                                     │
    ├──► koda-hub-federation (003) ◄── koda-life-master (004)             │
    │         │                           │                               │
    │         └───────────────────────────┼──► koda-agent-spec (005) ◄────┤
    │                                     │         │                     │
    │                                     │         ├──► koda-agent-construct (006)
    │                                     │         │                     │
    │                                     │         └──► koda-test-spec (007)
    │                                     │                               │
    └─────────────────────────────────────┴──► schema-versioning (008) ◄──┘
```

## Conceptos Clave

### KODA/Spec (Especificación de Conocimiento)

- Formato compatible con YAML para artefactos de conocimiento optimizados para RAG
- **Principios**: Fidelidad, Densidad, Semántica Estructural, Referenciación Interna
- **Léxico**: 20 keywords Tier-1 + vocabulario semántico abierto Tier-2
- **Keywords**: `Ctx_Required` y `Ctx_Optional` para clasificación explícita de dependencias

### KODA/Hub (Gestión del Hub de Conocimiento)

- Arquitectura de conocimiento federada con direccionamiento URN
- **Formato URN**: `urn:knowledge:{namespace}:{domain}:{artifact-id}:{version}`
- Manifiestos de artefactos, catálogo, resolver, versionado

### KODA/Life (Gestión del Ciclo de Vida de Agentes)

- Ciclo de vida de 5 fases: Concepción → Curación KB → Programación Agent → Testing → Mantenimiento
- Estrategia de control de versiones basada en Git
- Catálogo de patrones de diseño (10 patrones)

### KODA/Agent (Protocolo de Definición de Agentes)

- Schema YAML declarativo para especificación de agentes IA
- **7 Principios Core**: YAML es Código Fuente, La Estructura es Significado, Separación Protocolo/Contenido, Cartografía Explícita del Conocimiento, Abstracción Semántica, Agente como Categoría, Conocimiento Federado
- Instrucciones de runtime para ejecución LLM
- **JSON Schema**: `schemas/koda-agent-schema-1.0.0.json` para validación programática

### KODA/Test (Framework de Testing de Agentes)

- Metodología de testing estandarizada para agentes KODA
- **Categorías de Test**: Validación Estática, Testing Comportamental, Testing de Seguridad, Testing de Regresión
- Patrones de integración CI/CD
- Biblioteca de prompts adversariales para testing de seguridad

## Estructura de Artefactos

Cada artefacto sigue esta estructura obligatoria:

```yaml
# Comentario de cabecera con título y versión
_manifest:
  urn: "urn:knowledge:..."
  federation: { visibility, license }
  compatibility: { min_consumer_version }
  resolution: { canonical_url }
  dependencies: { requires: [...] }
  provenance: { created_by, dates, signature }

ID: ARTIFACT-ID-01
Version: 1.0.0
Status: Published
# ... campos de metadata ...

LLM_Parsing_Instructions:
  ID: KODA-LLM-PARSER-01
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    ...
    END_LLM_INSTRUCTIONS

# Secciones de contenido...
```

## Instrucciones de Parsing LLM (Canónicas)

Todos los artefactos usan las instrucciones de parsing estandarizadas:

```yaml
LLM_Parsing_Instructions:
  ID: KODA-LLM-PARSER-01
  Req: Bloque obligatorio después de Metadata.
  Prohib: Usar para creación o traducción de artefactos.
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    Eres un agente IA consumiendo un artefacto KODA. Parsea con fidelidad absoluta.

    FIDELIDAD: Preserva meat (información esencial) y skeleton (estructura) sin pérdida. Ignora fat (palabras de relleno, retórica).

    LÉXICO: Act->Acción, Cond->Condición, Ctx->Contexto, Ctx_Required->Referencia Externa Requerida, Ctx_Optional->Referencia Externa Opcional, Def->Definición, Ex->Ejemplo, Mssn->Misión, Obj->Objetivo, Proc->Proceso, Purp->Propósito, Ref->Referencia, Req->Requisito, Res->Resultado, Src->Fuente, Prohib->Prohibición, Warn->Advertencia, Just->Justificación, Rec->Recomendación

    POLÍTICA DE REFERENCIAS: Ref: es solo interno. Documentos externos usan Ctx:, Ctx_Required:, o Ctx_Optional:.

    POLÍTICA DE IDIOMA: Keywords en inglés, contenido en idioma original.
    END_LLM_INSTRUCTIONS
```

## Validación

Todos los artefactos pasan:

- ✓ Validación de sintaxis YAML 1.2
- ✓ IDs únicos dentro de cada documento
- ✓ Referencias internas válidas (Ref:)
- ✓ Estructura _manifest apropiada
- ✓ LLM_Parsing_Instructions estandarizadas
- ✓ Validación JSON Schema (para agent.yaml)

### Comandos Rápidos de Validación

```bash
# Usando KODA CLI (recomendado)
./scripts/koda validate

# Validación manual de sintaxis YAML
for f in knowledge/core/guide_core_*.yml; do
  python -c "import yaml; yaml.safe_load(open('$f'))" && echo "✓ $f" || echo "✗ $f"
done

# Validación de agent.yaml con schema (requiere ajv-cli)
npm install -g ajv-cli
ajv validate -s schemas/koda-agent-schema-1.0.0.json -d agents/*/agent*.yaml

# O usa la validación estricta integrada
./scripts/koda validate --strict
```

## Herramientas CLI

KODA incluye herramientas CLI interactivas para operaciones comunes:

```bash
# Ver todos los comandos
./scripts/koda --help

# Inicializar un nuevo repositorio KODA-compliant
./scripts/koda init <namespace> --type commercial

# Validar repositorio actual
./scripts/koda validate
./scripts/koda validate --strict  # Incluye validación JSON Schema

# Agregar nuevo artefacto interactivamente
./scripts/koda add

# Verificar salud de la federación
./scripts/koda health
./scripts/koda health --full  # Incluye checks remotos

# Sincronizar con registro de federación
./scripts/koda sync
```

### Instalación Global (opcional)

```bash
# Agregar al PATH para acceso global
echo 'export PATH="$HOME/Developer/koda/scripts:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Ahora puedes usar desde cualquier lugar
koda validate
koda health
```

## Convención de Nombres

```
{tipo}_{dominio}_{número}_{nombre}_{formato}.yml

tipo:    guide | kb
dominio: core | gn | custom
número:  001-999
nombre:  descripción-kebab-case
formato: koda
```

## Uso

### Para Arquitectos de Conocimiento

1. Usa `koda-spec` + `koda-transform` para crear nuevos artefactos KODA
2. Sigue `koda-hub-federation` para estructura de directorios y federación
3. Registra artefactos en el catálogo con URNs

### Para Desarrolladores de Agentes

1. **Empieza aquí**: `quickstart` para tu primer agente en 30 minutos
2. Sigue `koda-life-master` para metodología de ciclo de vida
3. Usa `koda-agent-spec` como referencia de schema
4. Aplica la metodología `koda-agent-construct` para construir agentes
5. Usa `koda-test-spec` para testear tus agentes

### Para Consumo por LLM

1. Cada artefacto incluye `LLM_Parsing_Instructions`
2. Parsea con fidelidad absoluta al meat/skeleton
3. Usa `Ref:` solo para enlaces internos

## Historial de Versiones

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0.0 | 2025-11-25 | Release inicial. Framework KODA completo con 10 guías core (incluyendo Hub & Federation), JSON Schemas, agente(s) de referencia, herramientas CLI, plantillas, registro y automatización GitHub Actions. |

## Autores

- **Creador Humano**: FS
- **Colaboradores Modelo**: IA-CLAUDE, IA-GEMINI

---

*KODA Framework — La base para construir agentes IA de grado producción con máxima fidelidad comportamental.*

# KODA Core Knowledge Base

> Especificaciones fundacionales del framework KODA para ingeniería de agentes IA.

## Contenido

Este directorio contiene las **11 guías core** que definen el framework KODA:

| #   | Archivo                                        | URN                                               | Descripción                                      |
| --- | ---------------------------------------------- | ------------------------------------------------- | ------------------------------------------------ |
| 0   | `guide_core_000_quickstart_koda.yml`           | `urn:knowledge:koda:core:quickstart:1.0.0`        | Guía de inicio rápido                            |
| 1   | `guide_core_001_koda-spec_koda.yml`            | `urn:knowledge:koda:core:spec:1.0.0`              | Especificación del formato KODA/Spec             |
| 2   | `guide_core_002_koda-transform_koda.yml`       | `urn:knowledge:koda:core:transform:1.0.0`         | Metodología de transformación de documentos      |
| 3   | `guide_core_003_koda-hub-master_koda.yml`      | `urn:knowledge:koda:core:hub:1.0.0`               | Gestión de Knowledge Hub federado                |
| 4   | `guide_core_004_koda-life-master_koda.yml`     | `urn:knowledge:koda:core:life:1.0.0`              | Ciclo de vida de agentes (5 fases)               |
| 5   | `guide_core_005_koda-agent-spec_koda.yml`      | `urn:knowledge:koda:core:agent:1.0.0`             | Especificación del protocolo KODA/Agent          |
| 6   | `guide_core_006_koda-agent-construct_koda.yml` | `urn:knowledge:koda:core:agent-construct:1.0.0`   | Metodología de construcción de agentes           |
| 7   | `guide_core_007_koda-test-spec_koda.yml`       | `urn:knowledge:koda:core:test:1.0.0`              | Framework de testing KODA/Test                   |
| 8   | `guide_core_008_schema-versioning_koda.yml`    | `urn:knowledge:koda:core:schema-versioning:1.0.0` | Política de versionado de schemas                |
| 9   | `guide_core_009_federation-protocol_koda.yml`  | `urn:knowledge:koda:core:federation:1.0.0`        | Protocolo de federación cross-repo               |
| 10  | `guide_core_010_koda-tooling-spec_koda.yml`    | `urn:knowledge:koda:core:tooling:1.0.0`           | Especificación de KODA/Tooling para herramientas |

## Arquitectura del Framework

```
┌───────────────────────────────────────────────────────────────────┐
│                        KODA Framework                             │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐           │
│  │  KODA/Spec  │───▶│  KODA/Hub   │◀───│ KODA/Agent  │           │
│  │  (Formato)  │    │ (Federación)│    │ (Protocolo) │           │
│  └─────────────┘    └──────┬──────┘    └─────────────┘           │
│         │                  │                  │                   │
│         ▼                  ▼                  ▼                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐           │
│  │  Transform  │    │    Life     │    │    Test     │           │
│  │ (Metodología)│    │(Ciclo Vida) │    │ (Validación)│           │
│  └─────────────┘    └─────────────┘    └─────────────┘           │
│                            │                                      │
│                            ▼                                      │
│                   ┌─────────────────┐                            │
│                   │   Federation    │ ◀── Cross-repo, Security,  │
│                   │   (Protocolo)   │     Health, Sync           │
│                   └─────────────────┘                            │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## Orden de Lectura Recomendado

### Para Principiantes
1. **Quickstart** → Visión general y primer agente
2. **KODA/Spec** → Entender el formato YAML estructurado
3. **KODA/Agent** → Protocolo de definición de agentes

### Para Implementadores
1. **Transform** → Cómo convertir documentos a KODA
2. **Agent-Construct** → Metodología paso a paso para construir agentes
3. **Test** → Validar y testear artefactos
4. **Tooling** → Configuración de herramientas y workflows de desarrollo

### Para Arquitectos
1. **Hub** → Gestión federada multi-repositorio
2. **Federation** → Protocolo de federación cross-repo (seguridad, health, sync)
3. **Life** → Ciclo completo de ingeniería de agentes
4. **Schema-Versioning** → Gobernanza de evolución de schemas

## Convención de Nombres

```
{tipo}_{dominio}_{número}_{descripción}_{namespace}.yml
```

| Componente    | Descripción              | Ejemplo                    |
| ------------- | ------------------------ | -------------------------- |
| `tipo`        | Tipo de artefacto        | `guide`, `kb`, `agent`     |
| `dominio`     | Categoría temática       | `core`, `legal`, `support` |
| `número`      | Secuencia ordenada       | `000`, `001`, `002`        |
| `descripción` | Nombre descriptivo       | `koda-spec`, `quickstart`  |
| `namespace`   | Organización propietaria | `koda`, `sanixai`          |

## Estructura de Manifiestos

Cada artefacto incluye un `_manifest` con:

```yaml
_manifest:
  urn: "urn:knowledge:koda:core:{artifact}:1.0.0"
  federation:
    visibility: public
    license: "CC-BY-4.0"
  compatibility:
    min_consumer_version: "1.0.0"
  resolution:
    canonical_url: "file://knowledge/core/{filename}"
  dependencies:
    requires: [...]
  provenance:
    created_by: "FS"
    created_at: "2025-11-25"
```

## Grafo de Dependencias

```
quickstart (entry point, sin dependencias)
     │
     ▼
   spec ◀───────────────────────────────────────────┐
     │                                               │
     ├──▶ transform                                  │
     │                                               │
     ├──▶ hub ──────▶ life ◀────▶ agent ────────────┤
     │     │            │           │                │
     │     │            ▼           ▼                │
     │     │        test      agent-construct        │
     │     │                        │                │
     │     ▼                        │                │
     │  federation ◀────────────────┘                │
     │  (resolver, health, sync, security)           │
     │                                               │
     └───────────────────────────────────────────────┘
                         │
                         ▼
                 schema-versioning
```

## Licencia

Todos los artefactos en este directorio están bajo licencia [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).

---

*Parte del [KODA Framework](../../README.md) — Knowledge-Oriented Design Architecture*

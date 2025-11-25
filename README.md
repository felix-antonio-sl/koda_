# KODA Framework — Knowledge-Oriented Declarative Agents

> **Current Release**: 2025-11-25  
> **Format**: KODA-YAML (Knowledge-Oriented Declarative Architecture)  
> **License**: CC-BY-4.0

## Overview

This corpus contains the foundational artifacts for **Agent Engineering** using the KODA Framework. It provides a complete, coherent framework for:

- **KODA/Spec** — Structured knowledge format (RAG-optimized YAML)
- **KODA/Agent** — Declarative agent definition protocol
- **KODA/Hub** — Federated knowledge management
- **KODA/Life** — Agent lifecycle management
- **KODA/Test** — Agent testing framework

## Quick Start

**New to the framework?** Start with the Quickstart guide:
```
knowledge/core/guide_core_000_quickstart_koda.yml → Build your first agent in 30 minutes
```

## Repository Structure

```
KODA/
├── knowledge/               # All knowledge artifacts
│   ├── core/               # Framework specifications
│   │   └── guide_core_*.yml
│   └── domains/            # Domain-specific KBs
├── agents/                 # Agent definitions
├── schemas/                # JSON Schemas
├── catalog/                # Artifact registry
├── sources/                # Source materials
└── staging/                # Work-in-progress (gitignored)
```

## Artifact Inventory

All core guides located in `knowledge/core/`:

| # | File | URN | Purpose |
|---|------|-----|---------|
| 000 | `guide_core_000_quickstart_koda.yml` | `urn:knowledge:gorenuble:core:quickstart:1.0.0` | **Quick start guide (START HERE)** |
| 001 | `guide_core_001_koda-spec_koda.yml` | `urn:knowledge:gorenuble:core:koda-spec:1.1.0` | KODA/Spec format specification (ROOT) |
| 002 | `guide_core_002_koda-transform_koda.yml` | `urn:knowledge:gorenuble:core:koda-transform:1.0.0` | KODA/Spec transformation methodology |
| 003 | `guide_core_003_koda-hub-master_koda.yml` | `urn:knowledge:gorenuble:core:koda-hub-master:1.0.0` | KODA/Hub Management |
| 004 | `guide_core_004_koda-life-master_koda.yml` | `urn:knowledge:gorenuble:core:koda-life-master:1.0.0` | KODA/Life Management |
| 005 | `guide_core_005_koda-agent-spec_koda.yml` | `urn:knowledge:gorenuble:core:koda-agent-spec:1.0.0` | KODA/Agent Protocol spec |
| 006 | `guide_core_006_koda-agent-construct_koda.yml` | `urn:knowledge:gorenuble:core:koda-agent-construct:1.0.0` | KODA/Agent construction methodology |
| 007 | `guide_core_007_koda-test-spec_koda.yml` | `urn:knowledge:gorenuble:core:koda-test-spec:1.0.0` | KODA/Test Framework |
| 008 | `guide_core_008_schema-versioning_koda.yml` | `urn:knowledge:gorenuble:core:schema-versioning:1.0.0` | Schema versioning policy |

### Schema Files

| File | Purpose |
|------|---------|
| `schemas/koda-agent-schema-1.0.0.json` | JSON Schema for agent.yaml validation |

## Dependency Graph

```
quickstart (000) ─────────────────────────────────────────────────────────┐
    │ (entry point)                                                       │
    ▼                                                                     │
koda-spec (001) ───────────────────────────────────────────────────────────┤
    │                                                                     │
    ├──► koda-transform (002)                                             │
    │                                                                     │
    ├──► koda-hub-master (003) ◄── koda-life-master (004)                 │
    │         │                           │                               │
    │         └───────────────────────────┼──► koda-agent-spec (005) ◄────┤
    │                                     │         │                     │
    │                                     │         ├──► koda-agent-construct (006)
    │                                     │         │                     │
    │                                     │         └──► koda-test-spec (007)
    │                                     │                               │
    └─────────────────────────────────────┴──► schema-versioning (008) ◄──┘
```

## Key Concepts

### KODA/Spec (Knowledge Specification)

- YAML-compliant format for RAG-optimized knowledge artifacts
- **Principles**: Fidelity, Density, Structural Semantics, Internal Referencing
- **Lexicon**: 20 Tier-1 keywords + open Tier-2 semantic vocabulary
- **New in v1.1**: `Ctx_Required` and `Ctx_Optional` for explicit dependency classification

### KODA/Hub (Knowledge Hub Management)

- Federated knowledge architecture with URN addressing
- **URN Format**: `urn:knowledge:{namespace}:{domain}:{artifact-id}:{version}`
- Artifact manifests, catalog, resolver, versioning

### KODA/Life (Agent Lifecycle Management)

- 5-phase lifecycle: Conception → KB Curation → Agent Programming → Testing → Maintenance
- Git-based version control strategy
- Design patterns catalog (10 patterns)

### KODA/Agent (Agent Definition Protocol)

- Declarative YAML schema for AI agent specification
- **7 Core Principles**: YAML is Source Code, Structure is Meaning, Protocol/Content Separation, Explicit Knowledge Cartography, Semantic Abstraction, Agent as Category, Federated Knowledge
- Runtime instructions for LLM execution
- **JSON Schema**: `schemas/koda-agent-schema-1.0.0.json` for programmatic validation

### KODA/Test (Agent Test Framework)

- Standardized testing methodology for KODA agents
- **Test Categories**: Static Validation, Behavioral Testing, Security Testing, Regression Testing
- CI/CD integration patterns
- Adversarial prompt library for security testing

## Structure

Each artifact follows this mandatory structure:

```yaml
# Header comment with title and version
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
# ... metadata fields ...

LLM_Parsing_Instructions:
  ID: KODA-LLM-PARSER-01
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    ...
    END_LLM_INSTRUCTIONS

# Content sections...
```

## LLM Parsing Instructions (Canonical)

All artifacts use the standardized parsing instructions:

```yaml
LLM_Parsing_Instructions:
  ID: KODA-LLM-PARSER-01
  Req: Mandatory block following Metadata.
  Prohib: Using for artifact creation or translation.
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    You are an AI agent consuming a KODA artifact. Parse with absolute fidelity.

    FIDELITY: Preserve meat (essential information) and skeleton (structure) with zero loss. Ignore fat (filler words, rhetoric).

    LEXICON: Act->Action, Cond->Condition, Ctx->Context, Ctx_Required->Required External Reference, Ctx_Optional->Optional External Reference, Def->Definition, Ex->Example, Mssn->Mission, Obj->Objective, Proc->Process, Purp->Purpose, Ref->Reference, Req->Requirement, Res->Result, Src->Source, Prohib->Prohibition, Warn->Warning, Just->Justification, Rec->Recommendation

    REFERENCE POLICY: Ref: is internal only. External documents use Ctx:, Ctx_Required:, or Ctx_Optional:.

    LANGUAGE POLICY: Keywords in English, content in original language.
    END_LLM_INSTRUCTIONS
```

## Validation

All artifacts pass:

- ✓ YAML 1.2 syntax validation
- ✓ Unique IDs within each document
- ✓ Valid internal references (Ref:)
- ✓ Proper _manifest structure
- ✓ Standardized LLM_Parsing_Instructions
- ✓ JSON Schema validation (for agent.yaml)

### Quick Validation Commands

```bash
# YAML syntax validation
for f in guide_core_*.yml; do
  python -c "import yaml; yaml.safe_load(open('$f'))" && echo "✓ $f" || echo "✗ $f"
done

# Agent.yaml schema validation (requires ajv-cli)
npm install -g ajv-cli
ajv validate --spec=draft2020 -s schemas/koda-agent-schema-1.0.0.json -d agent.yaml
```

## Naming Convention

```
{type}_{domain}_{number}_{name}_{format}.yml

type:   guide | kb
domain: core | gn | custom
number: 001-999
name:   kebab-case description
format: koda
```

## Usage

### For Knowledge Architects

1. Use `koda-spec` + `koda-transform` to create new KODA artifacts
2. Follow `koda-hub-master` for directory structure and federation
3. Register artifacts in catalog with URNs

### For Agent Developers

1. **Start here**: `quickstart` for your first agent in 30 minutes
2. Follow `koda-life-master` for lifecycle methodology
3. Use `koda-agent-spec` as schema reference
4. Apply `koda-agent-construct` methodology for agent building
5. Use `koda-test-spec` for testing your agents

### For LLM Consumption

1. Each artifact includes `LLM_Parsing_Instructions`
2. Parse with absolute fidelity to meat/skeleton
3. Use `Ref:` for internal links only

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-11-25 | **KODA Rebrand**: Renamed from STS to KODA Framework. Full terminology migration. |
| 1.1.0 | 2025-11-25 | Added: quickstart guide, KODA/Test framework, JSON Schema, schema versioning policy. |
| 1.0.0 | 2025-11-25 | Initial baseline release. All artifacts standardized. |

## Authors

- **Human-Creator**: FS
- **Model-Collaborators**: IA-CLAUDE, IA-GEMINI

---

*KODA Framework — The foundation for building production-grade AI agents with maximum behavioral fidelity.*

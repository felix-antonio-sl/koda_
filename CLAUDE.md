# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KODA (Knowledge-Oriented Declarative Agents) is a 100% declarative framework for AI agent engineering. No compiled code, no package managers, no build systems—all artifacts are YAML files designed for LLM consumption.

**Core Components:**
- **KODA/Spec** — RAG-optimized YAML knowledge format (20 Tier-1 keywords)
- **KODA/Agent** — Declarative agent definition protocol (7 namespaces)
- **KODA/Hub** — Federated knowledge with URN addressing
- **KODA/Life** — 5-phase lifecycle (Conception → KB Curation → Agent Programming → Testing → Maintenance)
- **KODA/Skills** — Write Once, Run Everywhere skills federation
- **KODA/Test** — Agent testing framework

## Common Commands

```bash
# Validate repository structure
./scripts/koda validate
./scripts/koda validate --strict    # Include JSON Schema checks

# Check federation health
./scripts/koda health
./scripts/koda health --full        # Include remote checks

# Sync with federation registry
./scripts/koda sync

# Initialize new KODA repository
./scripts/koda init <namespace>

# Skills management
./scripts/koda-skills.sh list
./scripts/koda-skills.sh sync --global
./scripts/koda-skills.sh push <namespace/skill> --target ws:<path>
```

**Manual validation:**
```bash
# YAML syntax check
python -c "import yaml; yaml.safe_load(open('path/to/file.yml'))"

# Agent schema validation (requires ajv-cli)
ajv validate -s schemas/koda-agent-schema-1.0.0.json -d agents/*/agent*.yaml
```

## Architecture

### Directory Structure

```
knowledge/core/          # 10 core framework guides (start with guide_core_000_quickstart_koda.yml)
knowledge/domains/       # Domain-specific knowledge artifacts
agents/                  # Reference agent definitions
skills/                  # MASTER: Skills repository (symlinked to .claude/ and .agent/)
  ├── koda/              # Framework skills
  ├── own/               # Personal skills
  └── community/         # Third-party skills
schemas/                 # JSON Schema (koda-agent-schema-1.0.0.json)
catalog/                 # Master registry (catalog_master_koda.yml)
scripts/                 # Bash CLI tools
registry/                # Federation namespace registry
staging/                 # Work-in-progress (not committed)
```

### Skills Federation

Skills propagate via symlinks:
- `.claude/skills → ../skills` (Claude Code)
- `.agent/skills → ../skills` (Antigravity)

Configuration in `skills/.skills-resolver.yml` defines propagation targets (global and workspace).

### URN Addressing

All artifacts use: `urn:knowledge:{namespace}:{domain}:{artifact-id}:{version}`

Resolution configured in `.knowledge-resolver.yml` (local override: `.knowledge-resolver.local.yml`).

**Active Namespaces:** koda, sanixai, gorenuble, tde, fxsl, orko

### KODA/Spec Lexicon (Tier-1)

Key abbreviations for knowledge artifacts:
- `Act` → Action, `Cond` → Condition, `Ctx` → Context
- `Ctx_Required` → Required External Reference, `Ctx_Optional` → Optional External Reference
- `Def` → Definition, `Ex` → Example, `Ref` → Internal Reference (internal only)
- `Req` → Requirement, `Prohib` → Prohibition, `Warn` → Warning, `Rec` → Recommendation

### Artifact Structure

Every YAML artifact follows:
```yaml
_manifest:
  urn: "urn:knowledge:..."
  federation: { visibility, license }
  dependencies: { requires: [...] }
  provenance: { created_by, dates }

ID: ARTIFACT-ID
Version: 1.0.0
Status: Published

LLM_Parsing_Instructions:
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    ...
    END_LLM_INSTRUCTIONS

# Content sections...
```

## Commit Convention

```
type(scope): subject

Types: feat | fix | kb | catalog | docs | refactor | test | chore
```

Examples:
- `feat(agents): add customer-service agent`
- `kb(legal): add contracts knowledge base v1.0.0`
- `fix(koda-spec): correct Ctx_Required definition`

## File Naming Convention

```
{type}_{domain}_{number}_{name}_{namespace}.yml

type:   guide | kb | agent
domain: core | gn | custom
number: 001-999
name:   kebab-case description
namespace: koda | sanixai | etc.
```

## Workflow for Adding Artifacts

1. Create artifact in `staging/`
2. Follow KODA/Spec format with mandatory `_manifest` block
3. Include `LLM_Parsing_Instructions` block
4. Validate YAML syntax
5. Move to appropriate directory
6. Register in `catalog/catalog_master_koda.yml`

**Creating agents and artifacts:** Use Agent Skills via conversation:
- "Create a new agent named [name]"
- "Create a new guide for [domain]"

## CI/CD Workflows

Located in `.github/workflows/`:
- **koda-validate.yml** — Runs on PR (validates structure + JSON schemas)
- **koda-audit.yml** — Weekly Monday audit, creates drift issues
- **koda-sync.yml** — Weekly federation sync + registry health check

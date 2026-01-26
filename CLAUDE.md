# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KODA (Knowledge-Oriented Declarative Agents) is a framework for declarative AI agent engineering using YAML-based specifications. The framework is 100% declarative—no compiled code, no package managers, no build systems. All artifacts are YAML files designed for LLM consumption.

**Key Components:**
- **KODA/Spec** — RAG-optimized YAML knowledge format
- **KODA/Agent** — Declarative agent definition protocol
- **KODA/Hub** — Federated knowledge management with URN addressing
- **KODA/Life** — 5-phase agent lifecycle (Conception → KB Curation → Agent Programming → Testing → Maintenance)
- **KODA/Test** — Agent testing framework
- **KODA/Skills** — Agent Skills repository (propagates to Claude Code & Antigravity via symlinks)

## Common Commands

```bash
# Validate repository structure
./scripts/koda validate

# Validate with JSON Schema checks
./scripts/koda validate --strict

# Add new artifact interactively
./scripts/koda add

# Check federation health
./scripts/koda health
./scripts/koda health --full

# Sync with federation registry
./scripts/koda sync

# Initialize new KODA repository
./scripts/koda init <namespace>
```

**Manual YAML validation:**
```bash
python -c "import yaml; yaml.safe_load(open('path/to/file.yml'))"
```

**Agent schema validation (requires ajv-cli):**
```bash
ajv validate -s schemas/koda-agent-schema-1.0.0.json -d agents/*/agent*.yaml
```

## Architecture

### Directory Structure

```
knowledge/core/          # 10 core framework guides (start with guide_core_000_quickstart_koda.yml)
knowledge/domains/       # Domain-specific knowledge artifacts
agents/                  # Reference agent definitions (10 agents)
skills/                  # MASTER: Agent Skills repository (symlinked to .claude/ and .agent/)
schemas/                 # JSON Schema for validation (koda-agent-schema-1.0.0.json)
catalog/                 # Master registry (catalog_master_koda.yml)
scripts/                 # Bash CLI tools
registry/                # Federation namespace registry
staging/                 # Work-in-progress (not committed)
tooling/                 # Workflows, rules, and profiles

# Symlinks for skill propagation:
.claude/skills → ../skills    # Claude Code
.agent/skills → ../skills     # Antigravity
```

### URN-Based Federation

All artifacts use URN addressing: `urn:knowledge:{namespace}:{domain}:{artifact-id}:{version}`

Resolution is configured in `.knowledge-resolver.yml`. The resolver is **speculative** (documents resolution) not **operative** (LLMs need physical file paths).

**Active Namespaces:** koda (framework), sanixai, gorenuble, tde, fxsl, orko

### KODA/Spec Keywords (Tier-1)

The framework uses a 20-keyword lexicon. Key abbreviations:
- `Act` → Action, `Cond` → Condition, `Ctx` → Context
- `Ctx_Required` → Required External Reference, `Ctx_Optional` → Optional External Reference
- `Def` → Definition, `Ex` → Example, `Mssn` → Mission
- `Ref` → Internal Reference (internal only), `Req` → Requirement
- `Prohib` → Prohibition, `Warn` → Warning, `Rec` → Recommendation

### Artifact Structure

Every YAML artifact follows this structure:
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

### Agent Structure

Agents are YAML specifications with 7 namespaces:
- Identity binding (role/objective/audience)
- State machine (initial_state → transitions)
- Knowledge base governance
- Security boundaries (block_instructions, forbid_jargon)
- Cognitive models (internal, never exposed)

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

## Skills Architecture

KODA serves as the **canonical repository** for Agent Skills, propagating to Claude Code and Antigravity via symlinks.

```
skills/                          ← SINGLE SOURCE OF TRUTH
├── skill-name/
│   ├── SKILL.md                 ← Required: skill definition
│   ├── scripts/                 ← Optional: executable scripts
│   ├── examples/                ← Optional: usage examples
│   └── resources/               ← Optional: supporting files
│
.claude/skills → ../skills       ← Symlink (Claude Code)
.agent/skills → ../skills        ← Symlink (Antigravity)
```

**Adding a skill:**
1. Create `skills/my-skill/SKILL.md` with front-matter (name, description)
2. Add optional scripts/examples/resources
3. Skill auto-propagates via symlinks

**URN format:** `urn:knowledge:koda:skills:{skill-name}:{version}`

## CI/CD Workflows

- **koda-validate.yml** — Runs on PR (validates structure + JSON schemas)
- **koda-audit.yml** — Weekly Monday audit, creates drift issues
- **koda-sync.yml** — Weekly federation sync + registry health check

# Contributing to KODA Framework

Thank you for your interest in contributing to KODA!

## Getting Started

1. **Read the Documentation**
   - Start with `guide_core_000_quickstart_koda.yml`
   - Review `README.md` for framework overview

2. **Understand the Structure**
   ```
   KODA/
   ├── guide_core_*.yml    # Core specification guides
   ├── schemas/            # JSON Schema definitions
   ├── agents/             # Agent definitions
   ├── domains/            # Domain-specific knowledge
   ├── staging/            # Work-in-progress (not committed)
   ├── sources/            # Source materials
   └── catalog/            # Master artifact registry
   ```

## Contribution Types

### Adding Knowledge Artifacts

1. Create artifact in `staging/` first
2. Follow KODA/Spec format (see `guide_core_001_koda-spec_koda.yml`)
3. Include mandatory `_manifest` block with URN
4. Validate YAML syntax
5. Move to appropriate directory when complete
6. Register in `catalog/catalog_master_koda.yml`

### Adding Agents

1. Follow KODA/Agent protocol (`guide_core_005_koda-agent-spec_koda.yml`)
2. Use `guide_core_006_koda-agent-construct_koda.yml` methodology
3. Validate against `schemas/koda-agent-schema-1.0.0.json`
4. Place in `agents/{agent-name}/agent.yaml`

### Improving Documentation

- Fix typos, clarify explanations
- Add examples
- Translate content (keeping keywords in English)

## Commit Convention

```
type(scope): subject

type:   feat | fix | kb | catalog | docs | refactor | test | chore
scope:  affected component (e.g., koda-spec, agent-architect)
subject: concise description
```

**Examples:**
```bash
feat(agents): add customer-service agent
kb(legal): add contracts knowledge base v1.0.0
fix(koda-spec): correct Ctx_Required definition
docs(readme): update installation instructions
```

## Pull Request Process

1. Create feature branch from `develop`
2. Make changes following conventions
3. Validate all YAML files
4. Update catalog if adding artifacts
5. Submit PR to `develop`
6. Address review feedback

## Code of Conduct

- Be respectful and constructive
- Focus on the technical merit
- Document your reasoning

## Questions?

Open an issue for:
- Clarification requests
- Feature proposals
- Bug reports

---

*KODA Framework — Building the future of declarative AI agents*

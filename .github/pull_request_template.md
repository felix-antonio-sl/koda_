## Description

<!-- Describe your changes -->

## Type of Change

- [ ] 📄 Knowledge artifact (new or modified)
- [ ] 🤖 Agent definition (new or modified)
- [ ] 📐 Schema change
- [ ] 🔧 Infrastructure (CI/CD, resolver, catalog)
- [ ] 📚 Documentation

## KODA Compliance Checklist

### For Knowledge Artifacts
- [ ] `_manifest` present with valid URN
- [ ] `_manifest.federation.visibility` set appropriately
- [ ] `_manifest.dependencies.requires` lists all dependencies
- [ ] `LLM_Parsing_Instructions` block included
- [ ] Added to `catalog/catalog_master_koda.yml`
- [ ] Added resolution rule to `.knowledge-resolver.yml`

### For Agent Definitions
- [ ] `_manifest` present with valid URN
- [ ] `KODA_Runtime_Instructions` block included
- [ ] All `source_artifacts` URNs are resolvable
- [ ] `block_instructions: true` set in safety constraints
- [ ] `forbid_internal_jargon: true` set

### For Schema Changes
- [ ] Backward compatible (MINOR) or documented breaking change (MAJOR)
- [ ] Version bumped according to semver
- [ ] Migration guide provided if breaking

## Testing

- [ ] YAML syntax validated
- [ ] All URN references resolve
- [ ] CI pipeline passes

## Related Issues

<!-- Link any related issues: Fixes #123, Relates to #456 -->

---

*By submitting this PR, I confirm that my contribution follows the [KODA Federation Protocol](knowledge/core/guide_core_009_federation-protocol_koda.yml).*

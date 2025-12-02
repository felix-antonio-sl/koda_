# KODA Federation Registry

> Official registry of namespaces participating in the KODA federated knowledge ecosystem.

## What is this?

This registry maintains the official list of namespaces that are part of the KODA federation. When you register your namespace here, other KODA-compliant repositories can discover and reference your artifacts.

## How to Register a New Namespace

### Prerequisites

Before registering, ensure your repository is KODA-compliant:

- [ ] `.knowledge-resolver.yml` exists at repository root
- [ ] `_meta.resolver_version` is "1.0.0" or higher
- [ ] `self.namespace` matches your desired namespace name
- [ ] `koda` namespace configured as upstream with fallback URL
- [ ] `catalog/catalog_master_{namespace}.yml` exists
- [ ] At least basic directory structure (`knowledge/`, `agents/`, etc.)

### Registration Steps

1. **Fork** this repository
2. **Edit** `registry/namespaces.yml`
3. **Add** your namespace entry:

```yaml
  your-namespace:
    status: pending  # Will be changed to 'active' after review
    type: commercial|institutional|personal|opensource
    owner: "Your Organization Name"
    repository: "github.com/your-org/your-repo"
    fallback_url: "https://raw.githubusercontent.com/your-org/your-repo/main/"
    visibility: public|internal|private
    license: "CC-BY-4.0|MIT|Proprietary|..."
    registered: "YYYY-MM-DD"
    description: "Brief description of your knowledge base"
    domains:
      - domain1
      - domain2
```

4. **Submit PR** with title: `Register namespace: {your-namespace}`
5. **Wait for validation** - We'll verify your repo is KODA-compliant
6. **Merge** - Once approved, your namespace is officially registered

## Namespace Types

| Type | Description | Example |
|------|-------------|---------|
| `framework` | Core KODA specifications | `koda` |
| `commercial` | Business/commercial use | `sanixai` |
| `institutional` | Government/public institutions | `gorenuble` |
| `personal` | Individual/private projects | `fxsl` |
| `opensource` | Open source projects | - |

## After Registration

Once registered, other repositories can:

1. **Discover** your namespace via this registry
2. **Configure** their resolver to point to your repo
3. **Reference** your artifacts via URN: `urn:knowledge:{your-namespace}:{domain}:{artifact}:{version}`

### Recommended: Add KODA Badge

Add to your README:

```markdown
[![KODA Compliant](https://img.shields.io/badge/KODA-Compliant-blue)](https://github.com/felix-antonio-sl/koda)
```

## Validation

We validate registrations by checking:

```bash
# 1. Resolver exists and is valid
curl -sf "https://raw.githubusercontent.com/{repo}/main/.knowledge-resolver.yml"

# 2. Catalog exists
curl -sf "https://raw.githubusercontent.com/{repo}/main/catalog/catalog_master_{ns}.yml"

# 3. Namespace matches
# self.namespace in resolver == requested namespace
```

## Questions?

Open an issue in this repository or contact the KODA maintainers.

---

*Part of the [KODA Framework](../README.md) — Knowledge-Oriented Design Architecture*

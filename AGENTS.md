# KODA Framework Project

Este repositorio define el framework KODA (Knowledge-Optimized Document Architecture).

## Estructura del Proyecto

- `knowledge/core/` - Especificaciones core del framework
- `agents/` - Agentes KODA de referencia
- `tooling/` - Workflows, rules, profiles
- `schemas/` - JSON schemas de validación

## Workflows Disponibles

- `/agent-validation` - Valida agentes KODA completamente
- `/kb-transformation` - Transforma documentos a KODA/Spec

## Convenciones

### YAML Formatting
Seguir estrictamente: @.windsurf/rules/yaml-strict.yml

### KODA Conventions
Nomenclatura y estructura: @.windsurf/rules/koda-conventions.yml

- Keywords en **inglés** (ID, Def, Ref, Purp, etc.)
- Contenido en **español** (es-CL)
- URNs para todas las referencias cross-artifact
- Catálogo como source of truth

## Principios KODA (P1-P7)

1. **Declarativo**: YAML es código, LLM es intérprete
2. **Encapsulación**: Auto-contenido, mónadas
3. **Separación**: Protocolo/Contenido
4. **Cartografía**: Catálogos explícitos
5. **Abstracción**: Densidad informacional
6. **Coherencia**: Categórica y estructural
7. **Federación**: URNs cross-namespace

## Comandos Útiles

```bash
# Validar repositorio
./scripts/koda-validate.sh --strict

# Ver catálogo
cat catalog/catalog_master_koda.yml
```

## Referencias

- Spec: `guide_core_001_koda-spec_koda.yml`
- Agent: `guide_core_005_koda-agent-spec_koda.yml`
- Tooling: `guide_core_010_koda-tooling-spec_koda.yml`

# KODA Skills — El Palacio Sagrado

> Repositorio maestro canónico de Agent Skills para el ecosistema KODA.

## Arquitectura de Propagación

```
KODA (Repositorio Maestro)
├── skills/                          ← FUENTE ÚNICA DE VERDAD
│   ├── skill-name/
│   │   ├── SKILL.md                 ← Definición principal
│   │   ├── scripts/                 ← Scripts opcionales
│   │   ├── examples/                ← Ejemplos de uso
│   │   └── resources/               ← Recursos adicionales
│   └── ...
│
├── .claude/skills → ../skills       ← Symlink (Claude Code)
└── .agent/skills → ../skills        ← Symlink (Antigravity)
```

## Compatibilidad

Este directorio implementa el **Agent Skills Open Standard**, compatible con:

| Plataforma | Ruta Nativa | Propagación |
|------------|-------------|-------------|
| Claude Code | `.claude/skills/` | Via symlink |
| Antigravity | `.agent/skills/` | Via symlink |

**Mismo formato interno**: front-matter, estructura de carpetas, y modelo de carga (progressive disclosure).

## Estructura de una Skill

```
skills/mi-skill/
├── SKILL.md           # REQUERIDO - Definición principal
├── scripts/           # Opcional - Scripts ejecutables
├── examples/          # Opcional - Ejemplos de invocación
└── resources/         # Opcional - Archivos de soporte
```

### Formato de SKILL.md

```markdown
---
name: nombre-skill
description: Descripción breve para el índice
version: 1.0.0
author: nombre
tags: [tag1, tag2]
---

# Nombre de la Skill

## Propósito
Qué hace esta skill.

## Instrucciones
Instrucciones detalladas para el agente.

## Ejemplos
Ejemplos de uso.
```

## Cómo Agregar una Skill

1. Crear directorio en `skills/tu-skill/`
2. Crear `SKILL.md` con front-matter requerido
3. Agregar scripts/examples/resources según necesidad
4. La skill se propaga automáticamente via symlinks

## Principios KODA para Skills

1. **Fuente Única de Verdad**: Skills viven solo en `skills/`, nunca duplicadas
2. **Propagación por Symlink**: Cero copia, cero drift
3. **Formato Estándar**: Compatible con Agent Skills Open Standard
4. **Versionado Git**: Skills evolucionan con el framework

## URN para Skills

```
urn:knowledge:koda:skills:{skill-name}:{version}
```

---

*KODA Skills — Where agents learn their craft.*

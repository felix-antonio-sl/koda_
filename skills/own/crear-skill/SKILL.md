---
name: crear-skill
description: Estructura y genera nuevas skills para el agente Antigravity siguiendo los estándares de calidad y jerarquía definidos. Úsese cuando el usuario solicite crear una nueva habilidad o skill.
---

# Creador de Skills de Antigravity

Instrucciones para generar directorios `agent/skills/` de alta calidad, predecibles y eficientes basados en los requerimientos del usuario.

## Cuándo usar esta skill

- Cuando el usuario solicite "crear una skill" o "nueva habilidad".
- Para estandarizar una skill existente siguiendo los lineamientos oficiales.
- Cuando se necesite generar la estructura de carpetas y archivos para una nueva funcionalidad del agente.

## 1. Requisitos Estructurales Principales

Cada skill que generes debe seguir estrictamente esta jerarquía de carpetas:

- `/` (Raíz del directorio de la skill)
- `SKILL.md` (Obligatorio: Lógica principal e instrucciones)
- `scripts/` (Opcional: Scripts de ayuda o automatización)
- `examples/` (Opcional: Implementaciones de referencia)
- `resources/` (Opcional: Plantillas o activos)

## 2. Estándares del Frontmatter (YAML)

El archivo `SKILL.md` debe comenzar con un encabezado YAML (frontmatter) siguiendo estas reglas estrictas:

- `name`: Usar formato infinitivo (ej.: `probar-codigo`). Máximo 64 caracteres. Solo minúsculas, números y guiones. **No uses nombres de marcas** en el nombre.
- `description`: Escrita en tercera persona. Debe incluir disparadores (keywords) específicos. Máximo 1024 caracteres.
- **Campos Opcionales (Compatibilidad Claude):**
  - `disable-model-invocation`: `true` si es una skill que solo debe ejecutar el usuario manualmente (acciones peligrosas).
  - `user-invocable`: `false` si es conocimiento pasivo que el usuario no debería invocar.
  - `allowed-tools`: Lista de herramientas permitidas (ej.: `Read, Grep`).

## 3. Principios de Redacción (Estilo Directo)

Al escribir el cuerpo de `SKILL.md`, adhierete a estas mejores prácticas:

- **Concisión**: Asume que el agente es inteligente. No expliques conceptos básicos (qué es un PDF, Git, etc.). Céntrate solo en la lógica única de la skill.
- **Divulgación Progresiva**: Mantén el archivo `SKILL.md` por debajo de las 500 líneas. Si se necesita más detalle, enlaza a archivos secundarios (ej.: Ver `AVANZADO.md`). Profundiza solo un nivel.
- **Barras de Ruta**: Usa siempre barras normales `/` para las rutas, nunca invertidas `\`.
- **Grados de Libertad**:
  - Usa **Viñetas (Bullet Points)** para tareas de alta libertad (heurística/criterio).
  - Usa **Bloques de Código** para libertad media (plantillas a rellenar).
  - Usa **Comandos Bash Específicos** para libertad baja (operaciones frágiles).

## 4. Flujo de Trabajo y Bucles de Retroalimentación

Para tareas complejas, incluye:

1. **Listas de Verificación (Checklists)**: Una lista en Markdown que el agente pueda copiar y actualizar para rastrear el estado.
2. **Bucles de Validación**: Un patrón de “Planificar–Validar–Ejecutar”.
3. **Gestión de Errores**: Las instrucciones para los scripts deben ser “cajas negras”.
4. **Sincronización Obligatoria**: Al finalizar la creación, **SIEMPRE** instruye ejecutar:
    - `koda skills sync --local` (para skills de proyecto)
    - `koda skills sync --global` (para skills personales/globales)
    - O `koda skills push` si se envía a un workspace específico.
    *Esto asegura que la skill sea visible tanto para Antigravity como para Claude Code.*

## 5. Plantilla de Salida

Cuando se te pida crear una skill, presenta el resultado en este formato:

### [Nombre de la Carpeta]

Ruta: `agent/skills/[nombre-de-skill]/`

#### [SKILL.md]

```markdown
---
name: [nombre-en-infinitivo]
description: [descripción en 3ª persona con keywords]
disable-model-invocation: [true/false] # Opcional: Bloquear ejecución automática
---

# [Título de la Skill]

## Cuándo usar esta skill
- [Disparador 1]
- [Disparador 2]

## Flujo de trabajo
[Insertar lista de verificación o guía paso a paso aquí]

## Instrucciones
[Lógica específica, fragmentos de código o reglas]

## Recursos
- [Enlace a scripts o resources]

[Archivos de Soporte]

(Si aplica, proporciona el contenido para scripts o examples)
```

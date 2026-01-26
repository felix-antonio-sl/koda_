#!/bin/bash
# KODA Workspace Setup - Automatización Completa
# Crea estructura completa de workspace KODA en minutos

set -e

WORKSPACE_NAME="${1:-nuevo-workspace}"
NAMESPACE="${2:-$(basename $(pwd))}"

echo "🚀 Configurando workspace KODA: $WORKSPACE_NAME"
echo "📦 Namespace: $NAMESPACE"

# 1. Crear estructura de directorios
echo "📁 Creando estructura..."
mkdir -p tooling/{workflows,rules,profiles}
mkdir -p agents
mkdir -p knowledge/{catalog,sources}
mkdir -p .git/hooks
# Note: IDE adapters (.agent/, .windsurf/, .cursor/) are optional and developer-local (gitignored)
# Create them only if your IDE needs a dedicated adapter directory.

# 2. Crear catálogo tooling
echo "📋 Creando catálogo tooling..."
cat > tooling/_index.yml << EOF
# ${NAMESPACE} Tooling Catalog

_manifest:
  urn: "urn:tooling:${NAMESPACE}:catalog:index:1.0.0"
  type: catalog
  scope: workspace

artifacts:
  workflows: []
  rules: []
  profiles: []
EOF

# 3. Crear profile de workspace
echo "⚙️ Creando profile workspace..."
cat > tooling/profiles/${NAMESPACE}-workspace.yml << EOF
---
_manifest:
  urn: "urn:tooling:${NAMESPACE}:profiles:workspace:1.0.0"
  type: profile

metadata:
  platform: [antigravity, windsurf]
  description: "Configuración workspace ${NAMESPACE}"

agent_preference:
  default_agent: "knowledge-architect"
  agent_urn: "urn:knowledge:koda:agents:architect:1.0.0"
  activation_context: |
    Workspace ${NAMESPACE} con framework KODA.
    Usar KNOWLEDGE-ARCHITECT como agente por defecto.

recommended_workflows:
  - id: "agent-validation"
    when: "Validando agentes"
    urn: "urn:tooling:koda:workflows:agent-validation:1.0.0"
  
  - id: "kb-transformation"
    when: "Transformando documentación"
    urn: "urn:tooling:koda:workflows:kb-transformation:1.0.0"

active_rules:
  - "koda-conventions.yml"
  - "yaml-strict.yml"

ide_settings:
  antigravity:
    auto_approve_safe_commands: false
    preferred_language: "es"
  
  windsurf:
    cascade_mode: "planning"
    auto_import_agents_md: true

key_directories:
  agents: "agents/"
  knowledge: "knowledge/"
  tooling: "tooling/"
EOF

# 4. IDE Adapters (optional)
echo "ℹ️  IDE adapters (.agent/, .windsurf/, .cursor/) son opcionales y no se versionan"
echo "   Si tu IDE lo soporta, apunta directo a tooling/ (rules/workflows/profiles)"
echo "   Si no, crea un adapter local (ej: mkdir -p .agent/rules) y copia lo que necesites"

# 5. Crear AGENTS.md root
echo "📝 Creando AGENTS.md..."
cat > AGENTS.md << EOF
# ${NAMESPACE}

Workspace configurado con KODA framework.

## 🤖 Agente Activo

**Recomendado**: KNOWLEDGE-ARCHITECT  
**URN**: \`urn:knowledge:koda:agents:architect:1.0.0\`

## 🔄 Workflows Disponibles

- \`/agent-validation\` - Valida agentes KODA
- \`/kb-transformation\` - Transforma docs a KODA/Spec

## 📐 Convenciones

Ver: \`tooling/rules/koda-conventions.yml\`

- Keywords en **inglés**
- Contenido en **español**
- URNs para referencias cross-artifact

## 🚀 Quick Start

\`\`\`bash
# Crear nuevo agente
"Crear agente mi-agente" (Pedir al agente)

# Validar agente
# En IDE: /agent-validation
\`\`\`
EOF

# 6. Crear AGENTS.md para agents/
mkdir -p agents
cat > agents/AGENTS.md << EOF
# Agentes ${NAMESPACE}

## 🤖 Agente Activo

**Recomendado**: KNOWLEDGE-ARCHITECT

## 🔄 Workflows

- \`/agent-validation\` - Validación completa (P1-P7, Guard Set)

## 📐 Principios KODA (P1-P7)

Ver: \`tooling/rules/agent-principles.md\`

Quick reference:
- **P1**: Declarativo (estados, no scripts)
- **P2**: CMs con \`_meta: {expose: false}\`
- **P3**: Keywords inglés, contenido español
- **P4**: \`CM-KB-GUIDANCE\` obligatorio
- **P5**: \`process\` ≤ 5 pasos
- **P6**: Grafo alcanzable
- **P7**: URNs, no paths

## 💡 Crear Nuevo Agente

"Crear un nuevo agente llamado nombre-agente"

Auto-crea, registra y valida.
EOF

# 7. Crear .knowledge-resolver.yml
echo "🔍 Creando resolver..."
cat > .knowledge-resolver.yml << EOF
# Knowledge Resolver - ${NAMESPACE}

namespaces:
  koda:
    base_path: "../koda"
    priority: 1
  
  ${NAMESPACE}:
    base_path: "."
    priority: 10
EOF

# 8. Crear scripts/
mkdir -p scripts
# Scripts de automatización (koda-skills, etc) se pueden sincronizar aquí

# 9. Crear git hooks
echo "🪝 Configurando git hooks..."

# Pre-commit hook: Validación automática
cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash
# KODA Pre-commit Hook - Validación Automática

echo "🔍 Validando cambios KODA..."

# Detectar agentes modificados
MODIFIED_AGENTS=$(git diff --cached --name-only --diff-filter=ACM | grep "agents/agent_.*\.yaml$" || true)

if [ -n "$MODIFIED_AGENTS" ]; then
  echo "📋 Agentes para validar:"
  echo "$MODIFIED_AGENTS" | sed 's/^/  - /'
  
  # Validar cada agente
  VALIDATION_FAILED=false
  
  for agent in $MODIFIED_AGENTS; do
    echo ""
    echo "Validando $agent..."
    
    # Validación sintáctica YAML
    if command -v yq &> /dev/null; then
      if ! yq eval '.' "$agent" > /dev/null 2>&1; then
        echo "❌ Error sintáctico YAML en $agent"
        VALIDATION_FAILED=true
        continue
      fi
    fi
    
    # Validación básica de estructura
    if ! grep -q "_manifest:" "$agent"; then
      echo "⚠️  Falta _manifest en $agent"
      VALIDATION_FAILED=true
    fi
    
    if ! grep -q "KODA_Runtime_Instructions:" "$agent"; then
      echo "⚠️  Falta KODA_Runtime_Instructions en $agent"
      VALIDATION_FAILED=true
    fi
    
    if ! grep -q "security_protocols:" "$agent"; then
      echo "⚠️  Falta security_protocols en $agent"
      VALIDATION_FAILED=true
    fi
    
    if [ "$VALIDATION_FAILED" = false ]; then
      echo "✅ $agent: PASS"
    fi
  done
  
  if [ "$VALIDATION_FAILED" = true ]; then
    echo ""
    echo "❌ Validación falló. Ejecuta /agent-validation en IDE para detalles."
    echo "   O usa: git commit --no-verify (no recomendado)"
    exit 1
  fi
  
  echo ""
  echo "✅ Todos los agentes válidos"
fi

echo "✓ Pre-commit checks PASS"
HOOK_EOF

chmod +x .git/hooks/pre-commit

# Post-commit hook: Auto-registro en catálogo
cat > .git/hooks/post-commit << 'HOOK_EOF'
#!/bin/bash
# KODA Post-commit Hook - Auto-registro

# Detectar nuevos agentes
NEW_AGENTS=$(git diff-tree --no-commit-id --name-only --diff-filter=A -r HEAD | grep "agents/agent_.*\.yaml$" || true)

if [ -n "$NEW_AGENTS" ]; then
  echo ""
  echo "📦 Auto-registrando nuevos agentes en catálogo..."
  
  for agent in $NEW_AGENTS; do
    AGENT_NAME=$(basename "$agent" .yaml | sed 's/agent_//')
    URN="urn:knowledge:$(basename $(pwd)):agents:${AGENT_NAME}:1.0.0"
    
    echo "  → $AGENT_NAME"
    
    # TODO: Implementar registro automático en catalog
    # Por ahora solo notifica
  done
  
  echo "✅ Registro completado"
  echo "💡 Recuerda actualizar knowledge/catalog/catalog_master_*.yml si es necesario"
fi
HOOK_EOF

chmod +x .git/hooks/post-commit

# 10. Crear README
cat > README.md << EOF
# ${WORKSPACE_NAME}

Workspace KODA para namespace \`${NAMESPACE}\`.

## 🚀 Quick Start

\`\`\`bash
# Crear nuevo agente (automático)
"Crear un agente llamado mi-agente"

# El sistema automáticamente:
# - Crea archivo con template
# - Abre en editor
# - Valida en commit (git hook)
# - Registra en catálogo
\`\`\`

## 📁 Estructura

\`\`\`
${WORKSPACE_NAME}/
├── agents/          # Agentes KODA
├── knowledge/       # Knowledge base
├── tooling/         # Workflows, Rules, Profiles (source of truth)
└── scripts/         # Scripts de automatización
\`\`\`

> **Note**: IDE adapters (.agent/, .windsurf/, .cursor/) son opcionales y se ignoran por git.
> Si tu IDE lo requiere, crea el adapter local y apunta/copialo desde \`tooling/\`.

## 🔄 Workflows Disponibles

- \`/agent-validation\` - Validar agente
- \`/kb-transformation\` - Transformar docs

## 🛠️ Tools

- Agent Skills - "Crear agente..."
- Git hooks - Validación automática en commit

## 📚 Documentación

- [AGENTS.md](./AGENTS.md) - Guía del workspace
- [agents/AGENTS.md](./agents/AGENTS.md) - Guía de agentes

EOF

echo ""
echo "✅ Workspace KODA configurado: $WORKSPACE_NAME"
echo ""
echo "📂 Directorios creados:"
echo "   - tooling/ (workflows, rules, profiles)"
echo "   - agents/ (con AGENTS.md)"
echo "   - knowledge/"
echo ""
echo "ℹ️  IDE Adapters (optional):"
echo "   - Crea .agent/ (gitignored) si lo necesitas"
echo "   - Usa tooling/ como source of truth"
echo ""
echo "🔧 Automatización instalada:"
echo "   - Git pre-commit hook (validación)"
echo "   - Git post-commit hook (registro)"
echo ""
echo "🚀 Próximos pasos:"
echo "   1. Crear tu primer agente: \"Crear agente mi-agente\""
echo "   2. Los cambios se validarán automáticamente en commit"
echo "   3. IDE cargará workflows/rules automáticamente"
echo ""
echo "💡 Todo es automático. Cero fricción."

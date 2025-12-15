#!/bin/bash
# =============================================================================
# KODA TOOLING CONTROL SYSTEM
# =============================================================================
# Unified script to manage IDE integrations and context files in KODA repos
#
# Usage: ./scripts/koda-tooling.sh <command> [options]
#
# Commands:
#   enable    Enable IDE integrations (adapters + AGENTS.md)
#   disable   Clean all generated files
#   status    Show current tooling status
#   sync      Re-sync AGENTS.md with index
#
# URN: urn:tooling:koda:scripts:tooling-control:1.0.0
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detect script location and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(pwd)"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

show_help() {
    echo -e "${CYAN}KODA Tooling Control System${NC}"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  enable       Enable IDE integrations"
    echo "  disable      Disable/clean IDE integrations"
    echo "  status       Show current status"
    echo "  sync         Sync AGENTS.md files with index"
    echo ""
    echo "Options for 'enable':"
    echo "  --all            Enable all (adapters + context files)"
    echo "  --adapters       Enable only IDE adapters (.agent, .windsurf)"
    echo "  --context        Enable only AGENTS.md files"
    echo "  --antigravity    Enable Antigravity adapter only"
    echo "  --windsurf       Enable Windsurf adapter only"
    echo "  --cursor         Enable Cursor adapter only"
    echo ""
    echo "Options for 'disable':"
    echo "  --all            Disable everything (adapters + context)"
    echo "  --adapters       Remove only IDE adapters"
    echo "  --context        Remove only AGENTS.md files"
    echo ""
    echo "Examples:"
    echo "  $0 enable --all           # Full setup"
    echo "  $0 disable --adapters     # Clean adapters, keep AGENTS.md"
    echo "  $0 status                 # Check what's enabled"
}

is_koda_repo() {
    # Check if this looks like a KODA-compliant repo
    if [ -d "tooling" ] || [ -d "knowledge" ] || [ -f ".knowledge-resolver.yml" ]; then
        return 0
    else
        return 1
    fi
}

get_namespace() {
    # Try to detect namespace from various sources
    if [ -f ".knowledge-resolver.yml" ]; then
        grep -m1 "namespace:" .knowledge-resolver.yml 2>/dev/null | cut -d: -f2 | tr -d ' "' || echo "$(basename $REPO_ROOT)"
    else
        echo "$(basename $REPO_ROOT)"
    fi
}

# =============================================================================
# ADAPTER GENERATION
# =============================================================================

generate_antigravity_adapter() {
    echo -e "${YELLOW}🔌 Generating Antigravity adapter (.agent/)...${NC}"
    
    mkdir -p .agent
    
    if [ -d "tooling/workflows" ]; then
        ln -sf ../tooling/workflows .agent/workflows
        echo -e "  ${GREEN}✓${NC} workflows linked"
    fi
    
    if [ -d "tooling/rules" ]; then
        ln -sf ../tooling/rules .agent/rules
        echo -e "  ${GREEN}✓${NC} rules linked"
    fi
    
    if [ -d "tooling/profiles" ]; then
        ln -sf ../tooling/profiles .agent/profiles
        echo -e "  ${GREEN}✓${NC} profiles linked"
    fi
    
    echo -e "${GREEN}✓ Antigravity adapter ready${NC}"
}

generate_windsurf_adapter() {
    echo -e "${YELLOW}🔌 Generating Windsurf adapter (.windsurf/)...${NC}"
    
    mkdir -p .windsurf
    
    if [ -d "tooling/workflows" ]; then
        ln -sf ../tooling/workflows .windsurf/workflows
        echo -e "  ${GREEN}✓${NC} workflows linked"
    fi
    
    if [ -d "tooling/rules" ]; then
        ln -sf ../tooling/rules .windsurf/rules
        echo -e "  ${GREEN}✓${NC} rules linked"
    fi
    
    # Generate .windsurfrules file
    if [ -f "tooling/rules/koda-conventions.yml" ]; then
        cat > .windsurf/.windsurfrules << 'RULES'
# Auto-generated from tooling/rules/
# See tooling/rules/ for source of truth

# KODA Core Rules
import: ../tooling/rules/koda-conventions.yml
import: ../tooling/rules/yaml-strict.yml
RULES
        echo -e "  ${GREEN}✓${NC} .windsurfrules generated"
    fi
    
    echo -e "${GREEN}✓ Windsurf adapter ready${NC}"
}

generate_cursor_adapter() {
    echo -e "${YELLOW}🔌 Generating Cursor adapter (.cursor/)...${NC}"
    
    mkdir -p .cursor
    
    if [ -d "tooling/workflows" ]; then
        ln -sf ../tooling/workflows .cursor/workflows
        echo -e "  ${GREEN}✓${NC} workflows linked"
    fi
    
    # Generate .cursorrules file
    cat > .cursor/.cursorrules << 'RULES'
# Auto-generated from tooling/rules/
# See tooling/rules/ for source of truth

# KODA Conventions
- Use URN format for references
- Keywords in English, content in Spanish
- All agents must pass P1-P7 validation
RULES
    echo -e "  ${GREEN}✓${NC} .cursorrules generated"
    
    echo -e "${GREEN}✓ Cursor adapter ready${NC}"
}

# =============================================================================
# CONTEXT FILES (AGENTS.MD) MANAGEMENT
# =============================================================================

generate_root_agents_md() {
    local NAMESPACE=$(get_namespace)
    
    if [ -f "AGENTS.md" ]; then
        echo -e "  ${YELLOW}⚠${NC} AGENTS.md exists, skipping (use --force to overwrite)"
        return
    fi
    
    cat > AGENTS.md << EOF
# ${NAMESPACE} Project

Este repositorio utiliza KODA framework.

## Estructura

- \`knowledge/\` - Artefactos de conocimiento
- \`agents/\` - Agentes KODA
- \`tooling/\` - Workflows, rules, profiles

## Workflows Disponibles

- \`/agent-validation\` - Valida agentes KODA
- \`/kb-transformation\` - Transforma docs a KODA/Spec

## Convenciones

Ver: \`tooling/rules/koda-conventions.yml\`

- Keywords en **inglés**
- Contenido en **español**
- URNs para referencias cross-artifact
EOF
    echo -e "  ${GREEN}✓${NC} AGENTS.md (root) created"
}

generate_agents_agents_md() {
    mkdir -p agents
    
    if [ -f "agents/AGENTS.md" ]; then
        echo -e "  ${YELLOW}⚠${NC} agents/AGENTS.md exists, skipping"
        return
    fi
    
    cat > agents/AGENTS.md << 'EOF'
# Agent Construction Guidelines

## Agente Recomendado

**KNOWLEDGE-ARCHITECT** - `urn:knowledge:koda:agents:architect:1.0.0`

## Workflow

`/agent-validation` - Antes de cada commit

## Principios KODA (P1-P7)

Ver: `tooling/rules/agent-principles.md`

- **P1**: Declarativo (estados, no scripts)
- **P2**: Monádico (CMs auto-contenidos)
- **P3**: Protocolo/Contenido separados
- **P4**: Cartografía (CM-KB-GUIDANCE)
- **P5**: Abstracción (≤5 pasos)
- **P6**: Coherencia (grafo alcanzable)
- **P7**: Federación (URNs)

## Nomenclatura

- Archivos: `agent_{nombre}.yaml`
- Estados: `S-{NOMBRE}`
- CMs: `CM-{PURPOSE}`
EOF
    echo -e "  ${GREEN}✓${NC} agents/AGENTS.md created"
}

generate_knowledge_agents_md() {
    mkdir -p knowledge
    
    if [ -f "knowledge/AGENTS.md" ]; then
        echo -e "  ${YELLOW}⚠${NC} knowledge/AGENTS.md exists, skipping"
        return
    fi
    
    cat > knowledge/AGENTS.md << 'EOF'
# Knowledge Base Guidelines - KODA/Spec

## Workflow

`/kb-transformation` - Para crear/modificar artefactos

## Fases de Transformación

1. Análisis (Meat/Fat/Skeleton)
2. Telegrafización (keywords + densidad)
3. Deduplicación (Ref: mechanism)
4. Validación (TER≥30%, FS=100%)

## Keywords Tier 1

- `ID:` - Identificador
- `Def:` - Definición
- `Ref:` - Referencia interna
- `XRef:` - Referencia externa (URN)

## Referencias

- Spec: `urn:knowledge:koda:core:spec:1.0.0`
- Rules: `tooling/rules/yaml-strict.yml`
EOF
    echo -e "  ${GREEN}✓${NC} knowledge/AGENTS.md created"
}

update_tooling_index() {
    if [ ! -f "tooling/_index.yml" ]; then
        echo -e "  ${YELLOW}⚠${NC} tooling/_index.yml not found, skipping index update"
        return
    fi
    
    # Check if context_files section already exists
    if grep -q "context_files:" tooling/_index.yml 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} context_files already in index"
        return
    fi
    
    # Append context_files section
    cat >> tooling/_index.yml << 'EOF'

# Context files for IDE AI assistance (AGENTS.md)
context_files:
  - path: "AGENTS.md"
    purpose: "Root project context for AI assistants"
  - path: "agents/AGENTS.md"
    purpose: "Agent construction guidelines"
  - path: "knowledge/AGENTS.md"
    purpose: "Knowledge artifacts guidelines"
EOF
    echo -e "  ${GREEN}✓${NC} tooling/_index.yml updated with context_files"
}

update_gitignore() {
    local ENTRIES=".agent/
.windsurf/
.cursor/"
    
    if [ ! -f ".gitignore" ]; then
        echo "$ENTRIES" > .gitignore
        echo -e "  ${GREEN}✓${NC} .gitignore created"
        return
    fi
    
    # Check if entries already exist
    if grep -q "\.agent/" .gitignore 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} .gitignore already has adapter entries"
        return
    fi
    
    echo "" >> .gitignore
    echo "# IDE Adapters (generated by koda-tooling.sh)" >> .gitignore
    echo "$ENTRIES" >> .gitignore
    echo -e "  ${GREEN}✓${NC} .gitignore updated"
}

# =============================================================================
# ENABLE COMMAND
# =============================================================================

cmd_enable() {
    local ENABLE_ADAPTERS=false
    local ENABLE_CONTEXT=false
    local ENABLE_ANTIGRAVITY=false
    local ENABLE_WINDSURF=false
    local ENABLE_CURSOR=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                ENABLE_ADAPTERS=true
                ENABLE_CONTEXT=true
                ENABLE_ANTIGRAVITY=true
                ENABLE_WINDSURF=true
                ENABLE_CURSOR=true
                shift
                ;;
            --adapters)
                ENABLE_ADAPTERS=true
                ENABLE_ANTIGRAVITY=true
                ENABLE_WINDSURF=true
                ENABLE_CURSOR=true
                shift
                ;;
            --context)
                ENABLE_CONTEXT=true
                shift
                ;;
            --antigravity)
                ENABLE_ADAPTERS=true
                ENABLE_ANTIGRAVITY=true
                shift
                ;;
            --windsurf)
                ENABLE_ADAPTERS=true
                ENABLE_WINDSURF=true
                shift
                ;;
            --cursor)
                ENABLE_ADAPTERS=true
                ENABLE_CURSOR=true
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done
    
    # Default to --all if nothing specified
    if ! $ENABLE_ADAPTERS && ! $ENABLE_CONTEXT; then
        ENABLE_ADAPTERS=true
        ENABLE_CONTEXT=true
        ENABLE_ANTIGRAVITY=true
        ENABLE_WINDSURF=true
        ENABLE_CURSOR=true
    fi
    
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           KODA Tooling - Enable                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Generate adapters
    if $ENABLE_ADAPTERS; then
        echo -e "${CYAN}=== IDE Adapters ===${NC}"
        $ENABLE_ANTIGRAVITY && generate_antigravity_adapter
        $ENABLE_WINDSURF && generate_windsurf_adapter
        $ENABLE_CURSOR && generate_cursor_adapter
        update_gitignore
        echo ""
    fi
    
    # Generate context files
    if $ENABLE_CONTEXT; then
        echo -e "${CYAN}=== Context Files (AGENTS.md) ===${NC}"
        generate_root_agents_md
        generate_agents_agents_md
        generate_knowledge_agents_md
        update_tooling_index
        echo ""
    fi
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Tooling Enabled Successfully                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
}

# =============================================================================
# DISABLE COMMAND
# =============================================================================

cmd_disable() {
    local DISABLE_ADAPTERS=false
    local DISABLE_CONTEXT=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                DISABLE_ADAPTERS=true
                DISABLE_CONTEXT=true
                shift
                ;;
            --adapters)
                DISABLE_ADAPTERS=true
                shift
                ;;
            --context)
                DISABLE_CONTEXT=true
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done
    
    # Default to adapters only (safer)
    if ! $DISABLE_ADAPTERS && ! $DISABLE_CONTEXT; then
        DISABLE_ADAPTERS=true
    fi
    
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           KODA Tooling - Disable                           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if $DISABLE_ADAPTERS; then
        echo -e "${CYAN}=== Removing IDE Adapters ===${NC}"
        [ -d ".agent" ] && rm -rf .agent && echo -e "  ${GREEN}✓${NC} .agent/ removed"
        [ -d ".windsurf" ] && rm -rf .windsurf && echo -e "  ${GREEN}✓${NC} .windsurf/ removed"
        [ -d ".cursor" ] && rm -rf .cursor && echo -e "  ${GREEN}✓${NC} .cursor/ removed"
        echo ""
    fi
    
    if $DISABLE_CONTEXT; then
        echo -e "${CYAN}=== Removing Context Files ===${NC}"
        [ -f "AGENTS.md" ] && rm AGENTS.md && echo -e "  ${GREEN}✓${NC} AGENTS.md removed"
        [ -f "agents/AGENTS.md" ] && rm agents/AGENTS.md && echo -e "  ${GREEN}✓${NC} agents/AGENTS.md removed"
        [ -f "knowledge/AGENTS.md" ] && rm knowledge/AGENTS.md && echo -e "  ${GREEN}✓${NC} knowledge/AGENTS.md removed"
        echo ""
    fi
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# =============================================================================
# STATUS COMMAND
# =============================================================================

cmd_status() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           KODA Tooling - Status                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local NAMESPACE=$(get_namespace)
    echo -e "📦 Namespace: ${CYAN}${NAMESPACE}${NC}"
    echo -e "📂 Repository: ${CYAN}${REPO_ROOT}${NC}"
    echo ""
    
    echo -e "${CYAN}=== Core Tooling ===${NC}"
    [ -d "tooling" ] && echo -e "  ${GREEN}✓${NC} tooling/" || echo -e "  ${RED}✗${NC} tooling/ (missing)"
    [ -d "tooling/workflows" ] && echo -e "  ${GREEN}✓${NC} tooling/workflows/" || echo -e "  ${YELLOW}○${NC} tooling/workflows/"
    [ -d "tooling/rules" ] && echo -e "  ${GREEN}✓${NC} tooling/rules/" || echo -e "  ${YELLOW}○${NC} tooling/rules/"
    [ -f "tooling/_index.yml" ] && echo -e "  ${GREEN}✓${NC} tooling/_index.yml" || echo -e "  ${YELLOW}○${NC} tooling/_index.yml"
    echo ""
    
    echo -e "${CYAN}=== IDE Adapters ===${NC}"
    [ -d ".agent" ] && echo -e "  ${GREEN}✓${NC} .agent/ (Antigravity)" || echo -e "  ${YELLOW}○${NC} .agent/ (not enabled)"
    [ -d ".windsurf" ] && echo -e "  ${GREEN}✓${NC} .windsurf/ (Windsurf)" || echo -e "  ${YELLOW}○${NC} .windsurf/ (not enabled)"
    [ -d ".cursor" ] && echo -e "  ${GREEN}✓${NC} .cursor/ (Cursor)" || echo -e "  ${YELLOW}○${NC} .cursor/ (not enabled)"
    echo ""
    
    echo -e "${CYAN}=== Context Files ===${NC}"
    [ -f "AGENTS.md" ] && echo -e "  ${GREEN}✓${NC} AGENTS.md (root)" || echo -e "  ${YELLOW}○${NC} AGENTS.md (missing)"
    [ -f "agents/AGENTS.md" ] && echo -e "  ${GREEN}✓${NC} agents/AGENTS.md" || echo -e "  ${YELLOW}○${NC} agents/AGENTS.md"
    [ -f "knowledge/AGENTS.md" ] && echo -e "  ${GREEN}✓${NC} knowledge/AGENTS.md" || echo -e "  ${YELLOW}○${NC} knowledge/AGENTS.md"
    echo ""
    
    echo -e "${CYAN}=== Git Integration ===${NC}"
    if [ -f ".gitignore" ]; then
        grep -q "\.agent/" .gitignore 2>/dev/null && echo -e "  ${GREEN}✓${NC} .gitignore has adapter entries" || echo -e "  ${YELLOW}○${NC} .gitignore missing adapter entries"
    else
        echo -e "  ${YELLOW}○${NC} .gitignore not found"
    fi
}

# =============================================================================
# SYNC COMMAND
# =============================================================================

cmd_sync() {
    echo -e "${BLUE}Syncing AGENTS.md files with tooling index...${NC}"
    update_tooling_index
    echo -e "${GREEN}✓ Sync complete${NC}"
}

# =============================================================================
# MAIN
# =============================================================================

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1
shift

case $COMMAND in
    enable)
        cmd_enable "$@"
        ;;
    disable)
        cmd_disable "$@"
        ;;
    status)
        cmd_status
        ;;
    sync)
        cmd_sync
        ;;
    -h|--help|help)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        echo "Run '$0 --help' for usage"
        exit 1
        ;;
esac

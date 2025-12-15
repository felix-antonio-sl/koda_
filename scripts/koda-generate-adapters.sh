#!/bin/bash
# KODA IDE Adapter Generator
# Generates IDE-specific adapter structures on demand
# Core tooling remains IDE-agnostic; this script creates symlinks for specific IDEs
#
# Usage: ./koda-generate-adapters.sh [--antigravity|--windsurf|--cursor|--all] [--clean]
#
# Spec: urn:knowledge:koda:core:tooling:1.0.0 (IDE_Decoupling_Policy)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Parse arguments
GENERATE_ANTIGRAVITY=false
GENERATE_WINDSURF=false
GENERATE_CURSOR=false
CLEAN_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --antigravity)
            GENERATE_ANTIGRAVITY=true
            shift
            ;;
        --windsurf)
            GENERATE_WINDSURF=true
            shift
            ;;
        --cursor)
            GENERATE_CURSOR=true
            shift
            ;;
        --all)
            GENERATE_ANTIGRAVITY=true
            GENERATE_WINDSURF=true
            GENERATE_CURSOR=true
            shift
            ;;
        --clean)
            CLEAN_MODE=true
            shift
            ;;
        -h|--help)
            echo "KODA IDE Adapter Generator"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --antigravity  Generate Antigravity adapter (.agent/)"
            echo "  --windsurf     Generate Windsurf adapter (.windsurf/)"
            echo "  --cursor       Generate Cursor adapter (.cursor/)"
            echo "  --all          Generate all adapters"
            echo "  --clean        Remove all generated adapters"
            echo "  -h, --help     Show this help"
            echo ""
            echo "Note: Adapter directories are .gitignore'd and not versioned."
            echo "      This keeps the core tooling IDE-agnostic."
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Default to showing help if no options
if ! $GENERATE_ANTIGRAVITY && ! $GENERATE_WINDSURF && ! $GENERATE_CURSOR && ! $CLEAN_MODE; then
    echo "Usage: $0 [--antigravity|--windsurf|--cursor|--all] [--clean]"
    echo "Run '$0 --help' for more information."
    exit 0
fi

cd "$REPO_ROOT"

# Verify tooling/ exists
if [ ! -d "tooling" ]; then
    echo -e "${RED}Error: tooling/ directory not found${NC}"
    echo "This script must be run from a KODA-compliant repository."
    exit 1
fi

# Clean mode
if $CLEAN_MODE; then
    echo -e "${YELLOW}🧹 Cleaning generated adapters...${NC}"
    
    if [ -d ".agent" ]; then
        rm -rf .agent
        echo -e "  ${GREEN}✓${NC} Removed .agent/"
    fi
    
    if [ -d ".windsurf" ]; then
        rm -rf .windsurf
        echo -e "  ${GREEN}✓${NC} Removed .windsurf/"
    fi
    
    if [ -d ".cursor" ]; then
        rm -rf .cursor
        echo -e "  ${GREEN}✓${NC} Removed .cursor/"
    fi
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
    exit 0
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           KODA IDE Adapter Generator                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Generate Antigravity adapter
if $GENERATE_ANTIGRAVITY; then
    echo -e "${YELLOW}🔌 Generating Antigravity adapter (.agent/)...${NC}"
    
    mkdir -p .agent
    
    # Create symlinks to tooling
    if [ -d "tooling/workflows" ]; then
        ln -sf ../tooling/workflows .agent/workflows
        echo -e "  ${GREEN}✓${NC} workflows -> tooling/workflows"
    fi
    
    if [ -d "tooling/rules" ]; then
        ln -sf ../tooling/rules .agent/rules
        echo -e "  ${GREEN}✓${NC} rules -> tooling/rules"
    fi
    
    if [ -d "tooling/profiles" ]; then
        ln -sf ../tooling/profiles .agent/profiles
        echo -e "  ${GREEN}✓${NC} profiles -> tooling/profiles"
    fi
    
    # Link to global KODA tooling if available
    if [ -d "$HOME/.koda/tooling/workflows" ]; then
        ln -sf "$HOME/.koda/tooling/workflows" .agent/workflows-global
        echo -e "  ${GREEN}✓${NC} workflows-global -> ~/.koda/tooling/workflows"
    fi
    
    echo -e "${GREEN}✓ Antigravity adapter ready${NC}"
    echo ""
fi

# Generate Windsurf adapter
if $GENERATE_WINDSURF; then
    echo -e "${YELLOW}🔌 Generating Windsurf adapter (.windsurf/)...${NC}"
    
    mkdir -p .windsurf
    
    # Create symlinks to tooling
    if [ -d "tooling/workflows" ]; then
        ln -sf ../tooling/workflows .windsurf/workflows
        echo -e "  ${GREEN}✓${NC} workflows -> tooling/workflows"
    fi
    
    # Create .windsurfrules explicit file (Windsurf specific requirement)
    if [ -f "tooling/rules/koda-conventions.yml" ]; then
        echo "# Auto-generated from tooling/rules/" > .windsurf/.windsurfrules
        echo "# See tooling/rules/ for source of truth" >> .windsurf/.windsurfrules
        echo "" >> .windsurf/.windsurfrules
        echo "# KODA Core Rules" >> .windsurf/.windsurfrules
        echo "import: ../tooling/rules/koda-conventions.yml" >> .windsurf/.windsurfrules
        echo "import: ../tooling/rules/agent-principles.md" >> .windsurf/.windsurfrules
        echo "import: ../tooling/rules/yaml-strict.yml" >> .windsurf/.windsurfrules
        echo -e "  ${GREEN}✓${NC} .windsurfrules generated"
    fi
    
    # Symlink to root .windsurfrules if needed by legacy versions, 
    # but preferred location is now handled via project context.
    # We keep the rules directory as a fallback/browsable location
    if [ -d "tooling/rules" ]; then
        ln -sf ../tooling/rules .windsurf/rules
        echo -e "  ${GREEN}✓${NC} rules directory linked"
    fi
    
    # Link to global KODA tooling if available
    if [ -d "$HOME/.koda/tooling/workflows" ]; then
        ln -sf "$HOME/.koda/tooling/workflows" .windsurf/workflows-global
        echo -e "  ${GREEN}✓${NC} workflows-global -> ~/.koda/tooling/workflows"
    fi
    
    echo -e "${GREEN}✓ Windsurf adapter ready${NC}"
    echo ""
fi

# Generate Cursor adapter
if $GENERATE_CURSOR; then
    echo -e "${YELLOW}🔌 Generating Cursor adapter (.cursor/)...${NC}"
    
    mkdir -p .cursor
    
    # Create symlinks to tooling
    if [ -d "tooling/workflows" ]; then
        ln -sf ../tooling/workflows .cursor/workflows
        echo -e "  ${GREEN}✓${NC} workflows -> tooling/workflows"
    fi
    
    # Cursor uses .cursorrules file - create if rules exist
    if [ -f "tooling/rules/koda-conventions.yml" ]; then
        echo "# Auto-generated from tooling/rules/" > .cursor/.cursorrules
        echo "# See tooling/rules/ for source of truth" >> .cursor/.cursorrules
        echo "" >> .cursor/.cursorrules
        echo "# KODA Conventions" >> .cursor/.cursorrules
        echo "- Use URN format for references" >> .cursor/.cursorrules
        echo "- Keywords in English, content in Spanish" >> .cursor/.cursorrules
        echo "- All agents must pass P1-P7 validation" >> .cursor/.cursorrules
        echo -e "  ${GREEN}✓${NC} .cursorrules generated"
    fi
    
    echo -e "${GREEN}✓ Cursor adapter ready${NC}"
    echo ""
fi

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Adapters Generated Successfully                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Note: Adapter directories are ${YELLOW}.gitignore'd${NC} (not versioned)."
echo -e "      The source of truth is ${BLUE}tooling/${NC}"
echo ""
echo -e "To remove adapters: ${BLUE}$0 --clean${NC}"

#!/bin/bash
# KODA Repository Validator
# Validates a KODA-compliant repository structure
# Usage: ./koda-validate.sh [--fix] [--verbose]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
ERRORS=0
WARNINGS=0
PASSED=0

# Resolver file detection (local override takes precedence)
get_resolver_file() {
    if [ -f ".knowledge-resolver.local.yml" ]; then
        echo ".knowledge-resolver.local.yml"
    elif [ -f ".knowledge-resolver.yml" ]; then
        echo ".knowledge-resolver.yml"
    else
        echo ""
    fi
}

# Options
FIX=false
VERBOSE=false
STRICT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --fix)
            FIX=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --strict|-s)
            STRICT=true
            shift
            ;;
        -h|--help)
            echo "Usage: koda-validate.sh [--fix] [--verbose] [--strict]"
            echo ""
            echo "Options:"
            echo "  --fix      Attempt to fix minor issues"
            echo "  --verbose  Show detailed output"
            echo "  --strict   Validate agents against JSON Schema (requires ajv or python jsonschema)"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           KODA Repository Validator                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Helper functions
pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "  ${BLUE}ℹ${NC} $1"
    fi
}

# ============================================================================
# 1. STRUCTURE CHECKS
# ============================================================================
echo -e "${YELLOW}1. Structure Checks${NC}"

# Check directories
for dir in knowledge knowledge/core agents catalog sources staging; do
    if [ -d "$dir" ]; then
        pass "Directory exists: $dir/"
    else
        fail "Missing directory: $dir/"
    fi
done

# ============================================================================
# 2. RESOLVER CHECKS
# ============================================================================
echo ""
echo -e "${YELLOW}2. Resolver Checks${NC}"

RESOLVER_FILE=$(get_resolver_file)
if [ -n "$RESOLVER_FILE" ]; then
    pass "Resolver exists: $RESOLVER_FILE"
    
    # Validate YAML syntax
    if command -v ruby &> /dev/null; then
        if ruby -ryaml -e "YAML.load_file('$RESOLVER_FILE')" 2>/dev/null; then
            pass "Resolver YAML syntax valid"
        else
            fail "Resolver YAML syntax invalid"
        fi
    elif command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$RESOLVER_FILE'))" 2>/dev/null; then
            pass "Resolver YAML syntax valid"
        else
            fail "Resolver YAML syntax invalid"
        fi
    else
        warn "Cannot validate YAML (no ruby or python3)"
    fi
    
    # Check required sections
    if grep -q "_meta:" "$RESOLVER_FILE"; then
        pass "Resolver has _meta section"
    else
        fail "Resolver missing _meta section"
    fi
    
    if grep -q "self:" "$RESOLVER_FILE"; then
        pass "Resolver has self section"
    else
        fail "Resolver missing self section"
    fi
    
    if grep -q "namespaces:" "$RESOLVER_FILE"; then
        pass "Resolver has namespaces section"
    else
        fail "Resolver missing namespaces section"
    fi
    
    # Check koda upstream
    if grep -q "koda:" "$RESOLVER_FILE"; then
        pass "Resolver has koda namespace configured"
    else
        warn "Resolver missing koda upstream (recommended)"
    fi
else
    fail "Missing .knowledge-resolver.yml (or .knowledge-resolver.local.yml)"
fi

# ============================================================================
# 3. CATALOG CHECKS
# ============================================================================
echo ""
echo -e "${YELLOW}3. Catalog Checks${NC}"

CATALOG_FILES=$(find catalog -name "catalog_master_*.yml" 2>/dev/null | head -1)

if [ -n "$CATALOG_FILES" ]; then
    pass "Catalog exists: $CATALOG_FILES"
    
    # Validate YAML syntax
    if command -v ruby &> /dev/null; then
        if ruby -ryaml -e "YAML.load_file('$CATALOG_FILES')" 2>/dev/null; then
            pass "Catalog YAML syntax valid"
        else
            fail "Catalog YAML syntax invalid"
        fi
    fi
    
    # Check _manifest
    if grep -q "_manifest:" "$CATALOG_FILES"; then
        pass "Catalog has _manifest"
    else
        fail "Catalog missing _manifest"
    fi
else
    fail "No catalog found in catalog/"
fi

# ============================================================================
# 4. ARTIFACT CHECKS
# ============================================================================
echo ""
echo -e "${YELLOW}4. Artifact Checks${NC}"

ARTIFACT_COUNT=0
MANIFEST_ERRORS=0

shopt -s nullglob
for f in knowledge/**/*.yml knowledge/**/*.yaml agents/**/*.yml agents/**/*.yaml; do
    if [ -f "$f" ]; then
        ARTIFACT_COUNT=$((ARTIFACT_COUNT + 1))
        
        # Check for _manifest
        if ! grep -q "_manifest:" "$f"; then
            if [ "$VERBOSE" = true ]; then
                warn "Missing _manifest in: $f"
            fi
            MANIFEST_ERRORS=$((MANIFEST_ERRORS + 1))
        fi
        
        # Validate YAML
        if command -v ruby &> /dev/null; then
            if ! ruby -ryaml -e "YAML.load_file('$f')" 2>/dev/null; then
                fail "Invalid YAML: $f"
            fi
        fi
    fi
done

if [ $ARTIFACT_COUNT -gt 0 ]; then
    pass "Found $ARTIFACT_COUNT artifacts"
    if [ $MANIFEST_ERRORS -gt 0 ]; then
        warn "$MANIFEST_ERRORS artifacts missing _manifest"
    else
        pass "All artifacts have _manifest"
    fi
else
    info "No artifacts found yet (empty repository)"
fi

# ============================================================================
# 5. GIT CHECKS
# ============================================================================
echo ""
echo -e "${YELLOW}5. Git Checks${NC}"

if [ -d ".git" ]; then
    pass "Git repository initialized"
else
    warn "Not a git repository (run 'git init')"
fi

if [ -f ".gitignore" ]; then
    pass ".gitignore exists"
    
    if grep -q "staging" .gitignore; then
        pass ".gitignore excludes staging/"
    else
        warn ".gitignore should exclude staging/"
    fi
else
    warn "Missing .gitignore"
fi

# ============================================================================
# 6. SCHEMA VALIDATION (--strict mode)
# ============================================================================
echo ""
echo -e "${YELLOW}6. Schema Validation${NC}"

if [ "$STRICT" = true ]; then
    # Find schema file
    SCHEMA_FILE=$(find . -name "koda-agent-schema-*.json" -path "*/schemas/*" 2>/dev/null | head -1)
    
    if [ -z "$SCHEMA_FILE" ]; then
        # Try upstream koda
        if [ -f "../koda/schemas/koda-agent-schema-1.0.0.json" ]; then
            SCHEMA_FILE="../koda/schemas/koda-agent-schema-1.0.0.json"
        fi
    fi
    
    if [ -n "$SCHEMA_FILE" ]; then
        pass "Schema found: $SCHEMA_FILE"
        
        # Check for validation tools
        VALIDATOR=""
        if command -v ajv &> /dev/null; then
            VALIDATOR="ajv"
        elif command -v python3 &> /dev/null && python3 -c "import jsonschema" 2>/dev/null; then
            VALIDATOR="python"
        fi
        
        if [ -n "$VALIDATOR" ]; then
            pass "Validator available: $VALIDATOR"
            
            # Validate all agent files
            AGENT_ERRORS=0
            for agent_file in agents/**/agent*.yaml agents/**/agent*.yml; do
                if [ -f "$agent_file" ]; then
                    if [ "$VALIDATOR" = "ajv" ]; then
                        if ajv validate -s "$SCHEMA_FILE" -d "$agent_file" 2>/dev/null; then
                            info "Schema valid: $agent_file"
                        else
                            fail "Schema invalid: $agent_file"
                            AGENT_ERRORS=$((AGENT_ERRORS + 1))
                        fi
                    elif [ "$VALIDATOR" = "python" ]; then
                        if python3 -c "
import json, yaml, sys
from jsonschema import validate, ValidationError
with open('$SCHEMA_FILE') as s:
    schema = json.load(s)
with open('$agent_file') as a:
    agent = yaml.safe_load(a)
try:
    validate(agent, schema)
except ValidationError as e:
    print(f'Validation error: {e.message}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null; then
                            info "Schema valid: $agent_file"
                        else
                            fail "Schema invalid: $agent_file"
                            AGENT_ERRORS=$((AGENT_ERRORS + 1))
                        fi
                    fi
                fi
            done
            
            if [ $AGENT_ERRORS -eq 0 ]; then
                pass "All agents pass schema validation"
            fi
        else
            warn "No schema validator found (install ajv: npm i -g ajv-cli, or: pip install jsonschema pyyaml)"
        fi
    else
        warn "No KODA agent schema found"
    fi
else
    info "Schema validation skipped (use --strict to enable)"
fi

# ============================================================================
# 7. CI/CD CHECKS
# ============================================================================
echo ""
echo -e "${YELLOW}7. CI/CD Checks${NC}"

if [ -d ".github/workflows" ]; then
    pass ".github/workflows/ exists"
    
    if [ -f ".github/workflows/koda-validate.yml" ]; then
        pass "Validation workflow exists"
    else
        warn "Missing koda-validate.yml workflow"
    fi
else
    warn "No GitHub workflows (optional)"
fi

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ VALIDATION PASSED${NC}"
    echo ""
    echo -e "  Passed:   ${GREEN}$PASSED${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "  Errors:   ${GREEN}$ERRORS${NC}"
    echo ""
    echo -e "Repository is ${GREEN}KODA-compliant${NC}"
    exit 0
else
    echo -e "${RED}✗ VALIDATION FAILED${NC}"
    echo ""
    echo -e "  Passed:   ${GREEN}$PASSED${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "  Errors:   ${RED}$ERRORS${NC}"
    echo ""
    echo -e "Fix the errors above and run again."
    exit 1
fi

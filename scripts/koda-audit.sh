#!/usr/bin/env bash
# =============================================================================
# KODA Audit Script
# Verifies consistency and integrity of the KODA framework
# =============================================================================

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRIFT_DETECTED=false
WARNINGS=0
ERRORS=0

echo "=============================================="
echo "  KODA Framework Audit"
echo "  $(date -Iseconds)"
echo "=============================================="
echo ""

# -----------------------------------------------------------------------------
# 1. LLM_Parsing_Instructions Consistency
# -----------------------------------------------------------------------------
echo "=== 1. LLM_Parsing_Instructions Consistency ==="

# Extract canonical version from koda-spec (the source of truth)
CANONICAL_FILE="knowledge/core/guide_core_001_koda-spec_koda.yml"
if [[ ! -f "$CANONICAL_FILE" ]]; then
    echo -e "${RED}❌ CRITICAL: Canonical file not found: $CANONICAL_FILE${NC}"
    exit 1
fi

# Get the LEXICON line as fingerprint (most likely to drift)
CANONICAL_LEXICON=$(grep "LEXICON" "$CANONICAL_FILE" | head -1 | md5sum | cut -d' ' -f1)

echo "Canonical fingerprint: $CANONICAL_LEXICON"
echo ""

# Check all guides
echo "Checking guides..."
for file in knowledge/core/guide_core_*.yml; do
    if [[ -f "$file" ]]; then
        CURRENT_LEXICON=$(grep "LEXICON" "$file" 2>/dev/null | head -1 | md5sum | cut -d' ' -f1)
        if [[ "$CURRENT_LEXICON" != "$CANONICAL_LEXICON" ]]; then
            echo -e "${RED}  ❌ DRIFT: $file${NC}"
            DRIFT_DETECTED=true
            ((ERRORS++))
        else
            echo -e "${GREEN}  ✓ OK: $file${NC}"
        fi
    fi
done

# NOTE: Agents do NOT require LLM_Parsing_Instructions block
# That block is only for knowledge artifacts (guides)
echo ""
echo "(Agents skipped - LLM_Parsing_Instructions not required for agent definitions)"
echo ""

# -----------------------------------------------------------------------------
# 2. Catalog Integrity
# -----------------------------------------------------------------------------
echo "=== 2. Catalog Integrity ==="

CATALOG_FILE="catalog/catalog_master_koda.yml"
if [[ ! -f "$CATALOG_FILE" ]]; then
    echo -e "${RED}❌ CRITICAL: Catalog not found${NC}"
    exit 1
fi

# Check all files referenced in catalog exist
echo "Checking file references..."
grep -E "^\s+file:" "$CATALOG_FILE" | sed 's/.*file:\s*//' | sed 's/"//g' | while read -r file; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}  ❌ MISSING: $file${NC}"
        DRIFT_DETECTED=true
        ((ERRORS++))
    fi
done

# Count entries vs actual files
CATALOG_COUNT=$(grep -c "urn:" "$CATALOG_FILE" || echo 0)
GUIDE_COUNT=$(find knowledge/core -name "guide_core_*.yml" | wc -l | tr -d ' ')
SCHEMA_COUNT=$(find schemas -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(find agents -name "agent_*.yaml" | wc -l | tr -d ' ')

echo ""
echo "Artifact counts:"
echo "  Catalog entries: $CATALOG_COUNT"
echo "  Core guides: $GUIDE_COUNT"
echo "  Schemas: $SCHEMA_COUNT"
echo "  Agents: $AGENT_COUNT"

echo ""

# -----------------------------------------------------------------------------
# 3. URN Resolution
# -----------------------------------------------------------------------------
echo "=== 3. URN Resolution ==="

# Find all URNs and verify they exist in catalog (best-effort)
echo "Checking URN resolution..."
UNRESOLVED_URNS=()

while IFS= read -r urn; do
    if [[ -n "$urn" ]] && ! grep -q "$urn" "$CATALOG_FILE"; then
        UNRESOLVED_URNS+=("$urn")
    fi
done < <(grep -rhoE "urn:knowledge:[a-z0-9:._-]+" knowledge/ agents/ 2>/dev/null | sort -u)

if [[ ${#UNRESOLVED_URNS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}  ⚠ Unresolved URNs (may be external):${NC}"
    for urn in "${UNRESOLVED_URNS[@]}"; do
        echo "    - $urn"
    done
    ((WARNINGS++))
else
    echo -e "${GREEN}  ✓ All URNs resolvable${NC}"
fi

echo ""

# -----------------------------------------------------------------------------
# 4. Federation Health (Local Files)
# -----------------------------------------------------------------------------
echo "=== 4. Federation Health ==="

RESOLVER_FILE=".knowledge-resolver.yml"
REGISTRY_FILE="registry/namespaces.yml"

if [[ -f "$RESOLVER_FILE" ]]; then
    echo -e "${GREEN}  ✓ Resolver exists${NC}"
else
    echo -e "${RED}  ❌ Resolver missing${NC}"
    DRIFT_DETECTED=true
    ((ERRORS++))
fi

if [[ -f "$REGISTRY_FILE" ]]; then
    NAMESPACE_COUNT=$(grep -c "^  [a-z]" "$REGISTRY_FILE" || echo 0)
    echo -e "${GREEN}  ✓ Registry exists ($NAMESPACE_COUNT namespaces)${NC}"
else
    echo -e "${RED}  ❌ Registry missing${NC}"
    DRIFT_DETECTED=true
    ((ERRORS++))
fi

echo ""

# -----------------------------------------------------------------------------
# 5. Version Consistency
# -----------------------------------------------------------------------------
echo "=== 5. Version Consistency ==="

# Check that all core guides have version in metadata
echo "Checking version declarations..."
for file in knowledge/core/guide_core_*.yml; do
    if [[ -f "$file" ]]; then
        if ! grep -q "Version:" "$file"; then
            echo -e "${YELLOW}  ⚠ No Version in: $file${NC}"
            ((WARNINGS++))
        fi
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "=============================================="
echo "  AUDIT SUMMARY"
echo "=============================================="
echo ""
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [[ "$DRIFT_DETECTED" == "true" ]] || [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}❌ AUDIT FAILED - Drift detected${NC}"
    exit 1
else
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠ AUDIT PASSED WITH WARNINGS${NC}"
    else
        echo -e "${GREEN}✅ AUDIT PASSED - No drift detected${NC}"
    fi
    exit 0
fi

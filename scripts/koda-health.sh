#!/bin/bash
# KODA Federation Health Check - Interactive
# Checks connectivity, dependencies, and sync status
# Usage: ./koda-health.sh [--full] [--fix]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Options
FULL_CHECK=false
FIX_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --full|-f)
            FULL_CHECK=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: koda-health.sh [--full] [--fix]"
            echo ""
            echo "Options:"
            echo "  --full, -f  Run full check including remote connectivity"
            echo "  --fix       Attempt to fix issues (update timestamps, etc.)"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

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

# Counters
HEALTHY=0
WARNINGS=0
ERRORS=0

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           KODA Federation Health Check                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if in KODA repo
RESOLVER_FILE=$(get_resolver_file)
if [ -z "$RESOLVER_FILE" ]; then
    echo -e "${RED}Error: Not in a KODA-compliant repository${NC}"
    echo -e "${RED}(no .knowledge-resolver.yml or .knowledge-resolver.local.yml found)${NC}"
    exit 1
fi

# Get namespace
if command -v ruby &> /dev/null; then
    NAMESPACE=$(ruby -ryaml -e 'puts YAML.load_file(ARGV[0]).dig("self", "namespace").to_s' "$RESOLVER_FILE" 2>/dev/null)
else
    NAMESPACE=$(grep -A1 "^self:" "$RESOLVER_FILE" | grep "namespace:" | awk -F: '{print $2}' | tr -d ' "' | tr -d ' ')
fi

if [ -z "$NAMESPACE" ]; then
    NAMESPACE="unknown"
fi
echo -e "Namespace: ${GREEN}${NAMESPACE}${NC}"
echo -e "Resolver:  ${CYAN}${RESOLVER_FILE}${NC}"
echo -e "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ============================================================================
# 1. LOCAL STRUCTURE
# ============================================================================
echo -e "${YELLOW}━━━ 1. Local Structure ━━━${NC}"
echo ""

check_dir() {
    if [ -d "$1" ]; then
        echo -e "  ${GREEN}●${NC} $1/"
        HEALTHY=$((HEALTHY + 1))
    else
        echo -e "  ${RED}○${NC} $1/ ${RED}(missing)${NC}"
        ERRORS=$((ERRORS + 1))
    fi
}

check_dir "knowledge"
check_dir "knowledge/core"
check_dir "agents"
check_dir "catalog"

echo ""

# ============================================================================
# 2. RESOLVER STATUS
# ============================================================================
echo -e "${YELLOW}━━━ 2. Resolver Status ━━━${NC}"
echo ""

# Check last sync
LAST_SYNC=""
if command -v ruby &> /dev/null; then
    LAST_SYNC=$(ruby -ryaml -e 'puts YAML.load_file(ARGV[0]).dig("_meta", "last_sync").to_s' "$RESOLVER_FILE" 2>/dev/null)
else
    LAST_SYNC=$(grep "last_sync:" "$RESOLVER_FILE" | head -1 | awk -F: '{print $2}' | tr -d ' "' | tr -d ' ')
fi

DAYS_AGO=-1

if [ -n "$LAST_SYNC" ]; then
    echo -e "  Last sync: ${CYAN}${LAST_SYNC}${NC}"
    
    # Calculate days since sync (rough estimate)
    if command -v python3 &> /dev/null; then
        DAYS_AGO=$(python3 -c "
from datetime import datetime, timezone
try:
    sync = datetime.fromisoformat('${LAST_SYNC}'.replace('Z', '+00:00'))
    now = datetime.now(timezone.utc)
    print((now - sync).days)
except:
    print(-1)
" 2>/dev/null)
        
        if [ "$DAYS_AGO" -ge 0 ]; then
            if [ "$DAYS_AGO" -gt 14 ]; then
                echo -e "  Status: ${RED}STALE${NC} (${DAYS_AGO} days ago)"
                WARNINGS=$((WARNINGS + 1))
                
                if [ "$FIX_MODE" = true ]; then
                    echo -e "  ${YELLOW}→ Updating last_sync timestamp...${NC}"
                    NEW_SYNC=$(date -u +%Y-%m-%dT%H:%M:%SZ)
                    sed -i.bak "s/last_sync:.*/last_sync: \"${NEW_SYNC}\"/" "$RESOLVER_FILE"
                    echo -e "  ${GREEN}✓ Updated to ${NEW_SYNC}${NC}"
                fi
            elif [ "$DAYS_AGO" -gt 7 ]; then
                echo -e "  Status: ${YELLOW}OK${NC} (${DAYS_AGO} days ago)"
                HEALTHY=$((HEALTHY + 1))
            else
                echo -e "  Status: ${GREEN}FRESH${NC} (${DAYS_AGO} days ago)"
                HEALTHY=$((HEALTHY + 1))
            fi
        fi
    else
        echo -e "  Status: ${YELLOW}Cannot calculate${NC} (python3 not available)"
    fi
else
    echo -e "  Last sync: ${RED}NOT SET${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Count configured namespaces
if command -v ruby &> /dev/null; then
    NS_COUNT=$(ruby -ryaml -e 'r = YAML.load_file(ARGV[0]); puts (r["namespaces"] || {}).keys.size' "$RESOLVER_FILE" 2>/dev/null)
else
    NS_COUNT=$(grep -E "^  [a-z].*:$" "$RESOLVER_FILE" | grep -v "_meta\\|self\\|resolution\\|directories\\|cache" | wc -l | tr -d ' ')
fi
echo -e "  Configured namespaces: ${CYAN}${NS_COUNT}${NC}"
echo ""

# ============================================================================
# 3. NAMESPACE CONNECTIVITY
# ============================================================================
echo -e "${YELLOW}━━━ 3. Namespace Connectivity ━━━${NC}"
echo ""

# Extract namespaces and check connectivity
if command -v ruby &> /dev/null; then
    ruby -ryaml -e '
resolver = YAML.load_file("'"$RESOLVER_FILE"'")
namespaces = resolver["namespaces"] || {}

namespaces.each do |name, config|
    next if config.nil?
    
    type = config["type"] || "unknown"
    base_path = config["base_path"]
    fallback = config["fallback"]
    required = config["required"]
    
    # Check local
    local_ok = base_path && File.exist?(base_path)
    
    print "  #{name}: "
    
    if local_ok
        puts "\033[0;32m● local\033[0m"
    elsif fallback
        puts "\033[1;33m◐ fallback only\033[0m"
    else
        if required
            puts "\033[0;31m○ unreachable\033[0m"
        else
            puts "\033[1;33m○ not configured\033[0m"
        end
    end
end
' 2>/dev/null
else
    echo -e "  ${YELLOW}Cannot check${NC} (ruby not available)"
fi

echo ""

# ============================================================================
# 4. REMOTE CONNECTIVITY (if --full)
# ============================================================================
if [ "$FULL_CHECK" = true ]; then
    echo -e "${YELLOW}━━━ 4. Remote Connectivity ━━━${NC}"
    echo ""
    
    # Check registry
    echo -n "  Registry: "
    if curl -sf "https://raw.githubusercontent.com/felix-antonio-sl/koda_/main/registry/namespaces.yml" > /dev/null 2>&1; then
        echo -e "${GREEN}● reachable${NC}"
        HEALTHY=$((HEALTHY + 1))
    else
        echo -e "${RED}○ unreachable${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check koda upstream
    echo -n "  KODA upstream: "
    if curl -sf "https://raw.githubusercontent.com/felix-antonio-sl/koda_/main/catalog/catalog_master_koda.yml" > /dev/null 2>&1; then
        echo -e "${GREEN}● reachable${NC}"
        HEALTHY=$((HEALTHY + 1))
    else
        echo -e "${RED}○ unreachable${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check fallback URLs from resolver
    echo ""
    echo "  Checking fallback URLs..."
    
    if command -v ruby &> /dev/null; then
        ruby -ryaml -e '
require "net/http"
require "uri"

resolver = YAML.load_file("'"$RESOLVER_FILE"'")
namespaces = resolver["namespaces"] || {}

namespaces.each do |name, config|
    next if config.nil?
    fallback = config["fallback"]
    next if fallback.nil? || fallback.empty?
    
    print "    #{name}: "
    
    begin
        uri = URI.parse(fallback)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = 5
        http.read_timeout = 5
        
        response = http.head(uri.path.empty? ? "/" : uri.path)
        
        if response.code.to_i < 400
            puts "\033[0;32m● #{response.code}\033[0m"
        else
            puts "\033[1;33m◐ #{response.code}\033[0m"
        end
    rescue => e
        puts "\033[0;31m○ error\033[0m"
    end
end
' 2>/dev/null
    fi
    
    echo ""
fi

# ============================================================================
# 5. DEPENDENCY ANALYSIS
# ============================================================================
echo -e "${YELLOW}━━━ 5. Dependency Analysis ━━━${NC}"
echo ""

# Count dependencies
if command -v ruby &> /dev/null; then
    NAMESPACE="$NAMESPACE" ruby -ryaml -e '
deps = []
Dir["knowledge/**/*.yml", "knowledge/**/*.yaml", "agents/**/*.yml", "agents/**/*.yaml"].each do |f|
    begin
        doc = YAML.load_file(f)
        next unless doc.is_a?(Hash) && doc["_manifest"]
        
        requires = doc["_manifest"]["dependencies"]&.[]("requires") || []
        requires.each do |dep|
            urn = dep.is_a?(Hash) ? dep["urn"] : dep
            deps << urn if urn
        end
    rescue
    end
end

namespace = ENV["NAMESPACE"].to_s
internal = deps.select { |d| d.start_with?("urn:knowledge:#{namespace}:") || d.start_with?("urn:tooling:#{namespace}:") }.uniq
external = deps.reject { |d| d.start_with?("urn:knowledge:#{namespace}:") || d.start_with?("urn:tooling:#{namespace}:") }.uniq

puts "  Internal dependencies: \033[0;36m#{internal.size}\033[0m"
puts "  External dependencies: \033[0;36m#{external.size}\033[0m"

if external.size > 0
    puts ""
    puts "  External URNs:"
    external.sort.first(10).each { |u| puts "    - #{u}" }
    puts "    ... and #{external.size - 10} more" if external.size > 10
end
' 2>/dev/null
else
    echo -e "  ${YELLOW}Cannot analyze${NC} (ruby not available)"
fi

echo ""

# ============================================================================
# 6. ARTIFACT HEALTH
# ============================================================================
echo -e "${YELLOW}━━━ 6. Artifact Health ━━━${NC}"
echo ""

TOTAL_ARTIFACTS=$(find knowledge -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l | tr -d ' ')
TOTAL_AGENTS=$(find agents -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l | tr -d ' ')
# Only count managed skills (koda and own) for catalog sync
TOTAL_SKILLS=$(find skills/koda skills/own -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
TOTAL_SCHEMAS=$(find schemas -name "*.json" 2>/dev/null | wc -l | tr -d ' ')

echo -e "  Knowledge artifacts: ${CYAN}${TOTAL_ARTIFACTS}${NC}"
echo -e "  Agent definitions:   ${CYAN}${TOTAL_AGENTS}${NC}"
echo -e "  Skill definitions:   ${CYAN}${TOTAL_SKILLS}${NC}"
echo -e "  Schema files:        ${CYAN}${TOTAL_SCHEMAS}${NC}"

# Check for drafts
DRAFTS=$(find knowledge -type f \( -name "*.yml" -o -name "*.yaml" \) -exec grep -l "Status: Draft" {} + 2>/dev/null | wc -l | tr -d ' ')
if [ "$DRAFTS" -gt 0 ]; then
    echo -e "  Draft artifacts:     ${YELLOW}${DRAFTS}${NC}"
fi

# Check for deprecated
DEPRECATED=$(find knowledge -type f \( -name "*.yml" -o -name "*.yaml" \) -exec grep -l "status: deprecated" {} + 2>/dev/null | wc -l | tr -d ' ')
if [ "$DEPRECATED" -gt 0 ]; then
    echo -e "  Deprecated:          ${YELLOW}${DEPRECATED}${NC}"
fi

echo ""

# ============================================================================
# 7. CATALOG SYNC
# ============================================================================
echo -e "${YELLOW}━━━ 7. Catalog Sync ━━━${NC}"
echo ""

CATALOG_FILE=$(find catalog -name "catalog_master_*.yml" 2>/dev/null | head -1)

if [ -n "$CATALOG_FILE" ]; then
    # Count entries in catalog (only file: entries, not manifest URNs or comments)
    CATALOG_COUNT=$(grep -E "^\s+file:" "$CATALOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
    ACTUAL_COUNT=$((TOTAL_ARTIFACTS + TOTAL_AGENTS + TOTAL_SCHEMAS + TOTAL_SKILLS))
    
    echo -e "  Catalog entries: ${CYAN}${CATALOG_COUNT}${NC}"
    echo -e "  Actual files:    ${CYAN}${ACTUAL_COUNT}${NC}"
    
    if [ "$CATALOG_COUNT" -ne "$ACTUAL_COUNT" ]; then
        echo -e "  Status: ${YELLOW}OUT OF SYNC${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  Status: ${GREEN}IN SYNC${NC}"
        HEALTHY=$((HEALTHY + 1))
    fi
else
    echo -e "  ${RED}No catalog found${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

TOTAL=$((HEALTHY + WARNINGS + ERRORS))

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}●${NC} FEDERATION HEALTH: ${GREEN}${BOLD}HEALTHY${NC}"
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}◐${NC} FEDERATION HEALTH: ${YELLOW}${BOLD}DEGRADED${NC}"
else
    echo -e "${RED}○${NC} FEDERATION HEALTH: ${RED}${BOLD}UNHEALTHY${NC}"
fi

echo ""
echo -e "  ${GREEN}●${NC} Healthy:  ${HEALTHY}"
echo -e "  ${YELLOW}◐${NC} Warnings: ${WARNINGS}"
echo -e "  ${RED}○${NC} Errors:   ${ERRORS}"
echo ""

# Recommendations
if [ "$WARNINGS" -gt 0 ] || [ "$ERRORS" -gt 0 ]; then
    echo -e "${YELLOW}Recommendations:${NC}"
    
    if [ "$DAYS_AGO" -gt 14 ] 2>/dev/null; then
        echo -e "  • Run ${CYAN}./scripts/koda-health.sh --fix${NC} to update sync timestamp"
    fi
    
    if [ "$CATALOG_COUNT" -ne "$ACTUAL_COUNT" ] 2>/dev/null; then
        echo -e "  • Update catalog to match actual artifacts"
    fi
    
    echo ""
fi

# Exit code
if [ "$ERRORS" -gt 0 ]; then
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    exit 0
else
    exit 0
fi

#!/bin/bash
# KODA Artifact Creator - Interactive
# Creates a new knowledge artifact with all required structure
# Usage: ./koda-add-artifact.sh [--type guide|kb|agent]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Get namespace from resolver
get_namespace() {
    if [ -f ".knowledge-resolver.yml" ]; then
        grep -A1 "^self:" .knowledge-resolver.yml | grep "namespace:" | sed 's/.*namespace: *"\?\([^"]*\)"\?/\1/' | tr -d ' '
    else
        echo ""
    fi
}

NAMESPACE=$(get_namespace)
DATE=$(date +%Y-%m-%d)

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           KODA Artifact Creator                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if in KODA repo
if [ ! -f ".knowledge-resolver.yml" ]; then
    echo -e "${RED}Error: Not in a KODA-compliant repository${NC}"
    echo "Run this script from the root of a KODA repository."
    exit 1
fi

echo -e "Namespace: ${GREEN}${NAMESPACE}${NC}"
echo ""

# ============================================================================
# Step 1: Artifact Type
# ============================================================================
echo -e "${YELLOW}Step 1: Artifact Type${NC}"
echo ""
echo "  1) guide  - Guide or specification document"
echo "  2) kb     - Knowledge base article"
echo "  3) agent  - Agent definition"
echo ""
read -p "Select type [1-3]: " TYPE_CHOICE

case $TYPE_CHOICE in
    1|guide) TYPE="guide" ;;
    2|kb) TYPE="kb" ;;
    3|agent) TYPE="agent" ;;
    *) 
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "  → Type: ${GREEN}${TYPE}${NC}"
echo ""

# ============================================================================
# Step 2: Domain
# ============================================================================
echo -e "${YELLOW}Step 2: Domain${NC}"
echo ""

if [ "$TYPE" = "agent" ]; then
    DOMAIN="agents"
    echo -e "  → Domain: ${GREEN}${DOMAIN}${NC} (automatic for agents)"
else
    echo "  Enter the knowledge domain (e.g., core, legal, hr, products)"
    echo ""
    read -p "  Domain: " DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        DOMAIN="core"
    fi
    
    # Validate domain format
    DOMAIN=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    echo -e "  → Domain: ${GREEN}${DOMAIN}${NC}"
fi
echo ""

# ============================================================================
# Step 3: Artifact Details
# ============================================================================
echo -e "${YELLOW}Step 3: Artifact Details${NC}"
echo ""

read -p "  Title (human readable): " TITLE
if [ -z "$TITLE" ]; then
    echo -e "${RED}Title is required${NC}"
    exit 1
fi

read -p "  ID (kebab-case, e.g., user-guide): " ARTIFACT_ID
if [ -z "$ARTIFACT_ID" ]; then
    # Generate from title
    ARTIFACT_ID=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
fi

read -p "  Description (one line): " DESCRIPTION
read -p "  Author: " AUTHOR
if [ -z "$AUTHOR" ]; then
    AUTHOR=$(git config user.name 2>/dev/null || echo "Unknown")
fi

echo ""
echo -e "  → ID: ${GREEN}${ARTIFACT_ID}${NC}"
echo -e "  → Author: ${GREEN}${AUTHOR}${NC}"
echo ""

# ============================================================================
# Step 4: Visibility & License
# ============================================================================
echo -e "${YELLOW}Step 4: Federation Settings${NC}"
echo ""
echo "  Visibility:"
echo "    1) public   - Anyone can access"
echo "    2) internal - Same organization only"
echo "    3) private  - Restricted access"
echo ""
read -p "  Select [1-3, default=1]: " VIS_CHOICE

case $VIS_CHOICE in
    2|internal) VISIBILITY="internal" ;;
    3|private) VISIBILITY="private" ;;
    *) VISIBILITY="public" ;;
esac

echo ""
echo "  License:"
echo "    1) CC-BY-4.0    - Creative Commons Attribution"
echo "    2) MIT          - MIT License"
echo "    3) Proprietary  - All rights reserved"
echo "    4) Other        - Custom"
echo ""
read -p "  Select [1-4, default=1]: " LIC_CHOICE

case $LIC_CHOICE in
    2|mit) LICENSE="MIT" ;;
    3|prop*) LICENSE="Proprietary" ;;
    4|other) 
        read -p "  Enter license: " LICENSE
        ;;
    *) LICENSE="CC-BY-4.0" ;;
esac

echo -e "  → Visibility: ${GREEN}${VISIBILITY}${NC}"
echo -e "  → License: ${GREEN}${LICENSE}${NC}"
echo ""

# ============================================================================
# Step 5: Generate Paths
# ============================================================================
echo -e "${YELLOW}Step 5: Generating Artifact${NC}"
echo ""

# Calculate sequence number
if [ "$TYPE" = "agent" ]; then
    DIR_PATH="agents/${ARTIFACT_ID}"
    FILENAME="agent_${ARTIFACT_ID}.yaml"
    FILE_PATH="${DIR_PATH}/${FILENAME}"
    URN="urn:knowledge:${NAMESPACE}:agents:${ARTIFACT_ID}:1.0.0"
else
    # Find next sequence number
    EXISTING=$(ls -1 knowledge/${DOMAIN}/${TYPE}_${DOMAIN}_*.yml 2>/dev/null | wc -l | tr -d ' ')
    SEQ_NUM=$(printf "%03d" $((EXISTING + 1)))
    
    FILENAME="${TYPE}_${DOMAIN}_${SEQ_NUM}_${ARTIFACT_ID}_${NAMESPACE}.yml"
    DIR_PATH="knowledge/${DOMAIN}"
    FILE_PATH="${DIR_PATH}/${FILENAME}"
    URN="urn:knowledge:${NAMESPACE}:${DOMAIN}:${ARTIFACT_ID}:1.0.0"
fi

# Create directory if needed
mkdir -p "$DIR_PATH"

echo -e "  File: ${CYAN}${FILE_PATH}${NC}"
echo -e "  URN:  ${CYAN}${URN}${NC}"
echo ""

# ============================================================================
# Step 6: Create File
# ============================================================================

if [ "$TYPE" = "agent" ]; then
    # Create agent file
    cat > "$FILE_PATH" << EOF
# ${TITLE}
# KODA Agent Definition
# Generated by koda-add-artifact.sh on ${DATE}

_manifest:
  urn: "${URN}"
  federation:
    visibility: ${VISIBILITY}
    license: "${LICENSE}"
  compatibility:
    min_consumer_version: "1.0.0"
    requires_koda_agent_schema: "1.0.0"
  resolution:
    canonical_url: "file://${FILE_PATH}"
  dependencies:
    requires:
      - urn: "urn:knowledge:koda:core:agent:1.0.0"
        reason: "Agent protocol specification"
  provenance:
    created_by: "${AUTHOR}"
    created_at: "${DATE}"
    last_modified_at: "${DATE}"

KODA_Runtime_Instructions:
  ID: KODA-RUNTIME-$(echo "$ARTIFACT_ID" | tr '[:lower:]-' '[:upper:]_')
  Activation: "You are now instantiating as the agent defined in this document."
  Content: |
    BEGIN_KODA_RUNTIME
    You are not merely reading this document—you ARE the agent it defines.
    Execute with absolute fidelity to the configuration below.
    END_KODA_RUNTIME

agent_identity_and_global_configuration:
  role: "${TITLE}"
  description: "${DESCRIPTION}"
  objective: "TODO: Define main objective"
  audience: "TODO: Define target audience"
  
  settings:
    content_lang: "es"
    response_style: "professional"

knowledge_base_interaction_and_governance_rules:
  usage_policy_and_source_management:
    policy: ONLY_FROM_DECLARED_SOURCES
    source_artifacts:
      - urn: "urn:knowledge:koda:core:spec:1.0.0"
      # TODO: Add knowledge sources
  uncertainty_protocol: DECLARE_UNCERTAINTY_WITH_REASONING

public_behavior_workflows_and_states:
  defined_workflows:
    WF-MAIN:
      initial_state: S-START

  states:
    S-START:
      id: S-START
      description: "Initial state"
      on_entry_actions:
        - "Greet user"
      transitions:
        - to: S-WORKING
          condition: "User provides request"

    S-WORKING:
      id: S-WORKING
      description: "Main working state"
      transitions:
        - to: S-END
          condition: "Task complete"

    S-END:
      id: S-END
      description: "Session end"
      on_entry_actions:
        - "Summarize and close"
      transitions: []

guard_set_and_interaction_boundaries:
  hard_constraints:
    block_instructions: true
    forbid_roleplay: true
    forbid_internal_jargon: true
EOF

else
    # Create knowledge artifact
    ID_UPPER=$(echo "${ARTIFACT_ID}" | tr '[:lower:]-' '[:upper:]_')
    
    cat > "$FILE_PATH" << EOF
# ${TITLE}
# KODA/Spec YAML Format
# Generated by koda-add-artifact.sh on ${DATE}

_manifest:
  urn: "${URN}"
  federation:
    visibility: ${VISIBILITY}
    license: "${LICENSE}"
  compatibility:
    min_consumer_version: "1.0.0"
    breaking_changes_from: null
  resolution:
    canonical_url: "file://${FILE_PATH}"
    mirrors: []
  dependencies:
    requires:
      - urn: "urn:knowledge:koda:core:spec:1.0.0"
        reason: "KODA/Spec format compliance"
  provenance:
    created_by: "${AUTHOR}"
    created_at: "${DATE}"
    last_modified_by: "${AUTHOR}"
    last_modified_at: "${DATE}"
    signature: null

ID: ${ID_UPPER}-01
Version: 1.0.0
Status: Draft
Human-Creator: ${AUTHOR}
Human-Editor: ${AUTHOR}
Model-Collaborator: null
Creation-Date: ${DATE}
Modification-Date: ${DATE}
Source: null
Ctx: ${DESCRIPTION}

LLM_Parsing_Instructions:
  ID: KODA-LLM-PARSER-01
  Req: Mandatory block following Metadata.
  Content: |
    BEGIN_LLM_INSTRUCTIONS
    You are an AI agent consuming a KODA artifact. Parse with absolute fidelity.
    FIDELITY: Preserve meat and skeleton with zero loss. Ignore fat.
    LEXICON: Def->Definition, Req->Requirement, Prohib->Prohibition, Ex->Example
    END_LLM_INSTRUCTIONS

Purp: ${DESCRIPTION}

# =============================================================================
# YOUR CONTENT STARTS HERE
# =============================================================================

Overview:
  ID: ${ID_UPPER}-OVERVIEW-01
  Purp: TODO - Add overview of this artifact

# Add your sections here following KODA/Spec conventions
EOF
fi

echo -e "  ${GREEN}✓${NC} Created: ${FILE_PATH}"

# ============================================================================
# Step 7: Update Catalog
# ============================================================================
echo ""
echo -e "${YELLOW}Step 6: Update Catalog?${NC}"
read -p "  Add to catalog? [Y/n]: " ADD_CATALOG

if [[ ! "$ADD_CATALOG" =~ ^[Nn] ]]; then
    CATALOG_FILE=$(find catalog -name "catalog_master_*.yml" | head -1)
    
    if [ -n "$CATALOG_FILE" ]; then
        # Determine section
        if [ "$TYPE" = "agent" ]; then
            SECTION="Agents"
        else
            SECTION="Core_Guides"
        fi
        
        echo ""
        echo -e "  ${YELLOW}⚠${NC} Manual step required:"
        echo -e "  Add this entry to ${CYAN}${CATALOG_FILE}${NC} under ${SECTION}:"
        echo ""
        echo -e "${CYAN}    - urn: \"${URN}\""
        echo "      title: \"${TITLE}\""
        echo "      file: \"${FILE_PATH}\""
        echo -e "      status: draft${NC}"
        echo ""
    fi
fi

# ============================================================================
# Step 8: Update Resolver
# ============================================================================
echo -e "${YELLOW}Step 7: Update Resolver?${NC}"
read -p "  Add resolution rule? [Y/n]: " ADD_RESOLVER

if [[ ! "$ADD_RESOLVER" =~ ^[Nn] ]]; then
    echo ""
    echo -e "  ${YELLOW}⚠${NC} Manual step required:"
    echo -e "  Add this rule to ${CYAN}.knowledge-resolver.yml${NC} under resolution_rules:"
    echo ""
    echo -e "${CYAN}  \"urn:knowledge:${NAMESPACE}:${DOMAIN}:${ARTIFACT_ID}:*\": \"./${FILE_PATH}\"${NC}"
    echo ""
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Artifact Created Successfully!                   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  File: ${CYAN}${FILE_PATH}${NC}"
echo -e "  URN:  ${CYAN}${URN}${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Edit ${CYAN}${FILE_PATH}${NC} to add content"
echo -e "  2. Update catalog (if not done)"
echo -e "  3. Update resolver (if not done)"
echo -e "  4. Run ${CYAN}./scripts/koda-validate.sh${NC}"
echo ""

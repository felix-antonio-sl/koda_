#!/bin/bash
# KODA Skills Manager
# Gestión federada de skills con propagación via symlinks
# Usage: koda skills <command> [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KODA_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$KODA_ROOT/skills"
RESOLVER="$SKILLS_DIR/.skills-resolver.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Expand tilde in paths
expand_path() {
    echo "${1/#\~/$HOME}"
}

show_help() {
    echo -e "${BOLD}KODA Skills Manager${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC} koda skills <command> [options]"
    echo ""
    echo -e "${BOLD}Commands:${NC}"
    echo ""
    echo -e "  ${GREEN}status${NC}              Show skills federation status"
    echo -e "  ${GREEN}list${NC}                List all skills"
    echo -e "  ${GREEN}list${NC} --ns <name>    List skills in namespace (koda|own|community)"
    echo -e "  ${GREEN}sync${NC} --global       Sync skills to global destinations"
    echo -e "  ${GREEN}sync${NC} --local        Sync skills to local workspace"
    echo -e "  ${GREEN}push${NC} <skill> --target ws:<path>  Push skill to workspace"
    echo -e "  ${GREEN}pull${NC} <skill>        Pull skill from KODA to current workspace"
    echo -e "  ${GREEN}install${NC} <url>       Install skill from git URL"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo ""
    echo -e "  ${CYAN}koda skills status${NC}"
    echo -e "  ${CYAN}koda skills list --ns koda${NC}"
    echo -e "  ${CYAN}koda skills sync --global${NC}"
    echo -e "  ${CYAN}koda skills push own/context-manager --target ws:~/Developer/sanixai${NC}"
    echo -e "  ${CYAN}koda skills pull koda/koda-artifact-helper${NC}"
    echo ""
}

cmd_status() {
    echo -e "${BOLD}KODA Skills Federation Status${NC}"
    echo ""

    # Count skills per namespace
    local koda_count=$(find "$SKILLS_DIR/koda" -maxdepth 1 -type d 2>/dev/null | wc -l)
    local own_count=$(find "$SKILLS_DIR/own" -maxdepth 1 -type d 2>/dev/null | wc -l)
    local community_count=$(find "$SKILLS_DIR/community" -maxdepth 1 -type d 2>/dev/null | wc -l)

    # Adjust counts (subtract 1 for the directory itself)
    koda_count=$((koda_count - 1))
    own_count=$((own_count - 1))
    community_count=$((community_count - 1))

    echo -e "${BOLD}Namespaces:${NC}"
    echo -e "  ${CYAN}koda/${NC}       $koda_count skills (framework)"
    echo -e "  ${CYAN}own/${NC}        $own_count skills (personal)"
    echo -e "  ${CYAN}community/${NC}  $community_count skills (third-party)"
    echo ""

    echo -e "${BOLD}Global Targets:${NC}"
    local claude_global=$(expand_path "~/.claude/skills")
    local ag_global=$(expand_path "~/.gemini/antigravity/skills")

    if [ -L "$claude_global" ]; then
        local target=$(readlink "$claude_global")
        echo -e "  ${GREEN}✓${NC} ~/.claude/skills → $target"
    elif [ -d "$claude_global" ]; then
        echo -e "  ${YELLOW}◐${NC} ~/.claude/skills (directory, not symlink)"
    else
        echo -e "  ${RED}✗${NC} ~/.claude/skills (not configured)"
    fi

    if [ -L "$ag_global" ]; then
        local target=$(readlink "$ag_global")
        echo -e "  ${GREEN}✓${NC} ~/.gemini/antigravity/skills → $target"
    elif [ -d "$ag_global" ]; then
        echo -e "  ${YELLOW}◐${NC} ~/.gemini/antigravity/skills (directory, not symlink)"
    else
        echo -e "  ${RED}✗${NC} ~/.gemini/antigravity/skills (not configured)"
    fi
    echo ""

    echo -e "${BOLD}Local Targets (KODA):${NC}"
    if [ -L "$KODA_ROOT/.claude/skills" ]; then
        echo -e "  ${GREEN}✓${NC} .claude/skills → $(readlink "$KODA_ROOT/.claude/skills")"
    else
        echo -e "  ${RED}✗${NC} .claude/skills (not configured)"
    fi

    if [ -L "$KODA_ROOT/.agent/skills" ]; then
        echo -e "  ${GREEN}✓${NC} .agent/skills → $(readlink "$KODA_ROOT/.agent/skills")"
    else
        echo -e "  ${RED}✗${NC} .agent/skills (not configured)"
    fi
    echo ""
}

cmd_list() {
    local namespace="all"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ns|--namespace)
                namespace="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${BOLD}KODA Skills${NC}"
    echo ""

    list_namespace() {
        local ns=$1
        local ns_path="$SKILLS_DIR/$ns"

        if [ -d "$ns_path" ]; then
            echo -e "${CYAN}$ns/${NC}"
            for skill_dir in "$ns_path"/*/; do
                if [ -d "$skill_dir" ]; then
                    local skill_name=$(basename "$skill_dir")
                    local skill_md="$skill_dir/SKILL.md"

                    if [ -f "$skill_md" ]; then
                        # Extract description from frontmatter
                        local desc=$(grep -A1 "^description:" "$skill_md" 2>/dev/null | tail -1 | sed 's/^description: *//' | head -c 60)
                        echo -e "  ${GREEN}$skill_name${NC}"
                        if [ -n "$desc" ]; then
                            echo -e "    ${YELLOW}$desc${NC}"
                        fi
                    else
                        echo -e "  ${GREEN}$skill_name${NC} ${RED}(no SKILL.md)${NC}"
                    fi
                fi
            done
            echo ""
        fi
    }

    if [ "$namespace" = "all" ]; then
        list_namespace "koda"
        list_namespace "own"
        list_namespace "community"
    else
        list_namespace "$namespace"
    fi
}

cmd_sync() {
    local scope="all"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --global)
                scope="global"
                shift
                ;;
            --local)
                scope="local"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${BOLD}Syncing KODA Skills...${NC}"
    echo ""

    if [ "$scope" = "global" ] || [ "$scope" = "all" ]; then
        echo -e "${CYAN}Global targets:${NC}"

        # Claude Code global
        local claude_global=$(expand_path "~/.claude/skills")
        if [ -e "$claude_global" ] && [ ! -L "$claude_global" ]; then
            echo -e "  ${YELLOW}⚠${NC} ~/.claude/skills exists but is not a symlink"
            echo -e "      Run: rm -rf ~/.claude/skills && ln -sf $SKILLS_DIR ~/.claude/skills"
        else
            rm -f "$claude_global" 2>/dev/null
            ln -sf "$SKILLS_DIR" "$claude_global"
            echo -e "  ${GREEN}✓${NC} ~/.claude/skills → $SKILLS_DIR"
        fi

        # Antigravity global
        local ag_global=$(expand_path "~/.gemini/antigravity/skills")
        if [ -e "$ag_global" ] && [ ! -L "$ag_global" ]; then
            echo -e "  ${YELLOW}⚠${NC} ~/.gemini/antigravity/skills exists but is not a symlink"
            echo -e "      Run: rm -rf ~/.gemini/antigravity/skills && ln -sf $SKILLS_DIR ~/.gemini/antigravity/skills"
        else
            rm -f "$ag_global" 2>/dev/null
            ln -sf "$SKILLS_DIR" "$ag_global"
            echo -e "  ${GREEN}✓${NC} ~/.gemini/antigravity/skills → $SKILLS_DIR"
        fi
        echo ""
    fi

    if [ "$scope" = "local" ] || [ "$scope" = "all" ]; then
        echo -e "${CYAN}Local targets (KODA):${NC}"

        # Ensure directories exist
        mkdir -p "$KODA_ROOT/.claude" "$KODA_ROOT/.agent"

        # Claude local
        rm -f "$KODA_ROOT/.claude/skills" 2>/dev/null
        ln -sf "../skills" "$KODA_ROOT/.claude/skills"
        echo -e "  ${GREEN}✓${NC} .claude/skills → ../skills"

        # Agent local
        rm -f "$KODA_ROOT/.agent/skills" 2>/dev/null
        ln -sf "../skills" "$KODA_ROOT/.agent/skills"
        echo -e "  ${GREEN}✓${NC} .agent/skills → ../skills"
        echo ""
    fi

    # Update last_sync in resolver
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/last_sync:.*/last_sync: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"/" "$RESOLVER"
    else
        sed -i "s/last_sync:.*/last_sync: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"/" "$RESOLVER"
    fi

    echo -e "${GREEN}Sync complete!${NC}"
}

cmd_push() {
    local skill="$1"
    shift
    local target=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                target="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -z "$skill" ]; then
        echo -e "${RED}Error: skill name required${NC}"
        echo "Usage: koda skills push <namespace/skill> --target ws:<path>"
        exit 1
    fi

    if [ -z "$target" ]; then
        echo -e "${RED}Error: target required${NC}"
        echo "Usage: koda skills push <namespace/skill> --target ws:<path>"
        exit 1
    fi

    # Parse target
    if [[ "$target" == ws:* ]]; then
        local ws_path=$(expand_path "${target#ws:}")
        local skill_source="$SKILLS_DIR/$skill"

        if [ ! -d "$skill_source" ]; then
            echo -e "${RED}Error: skill '$skill' not found in $SKILLS_DIR${NC}"
            exit 1
        fi

        if [ ! -d "$ws_path" ]; then
            echo -e "${RED}Error: workspace path '$ws_path' does not exist${NC}"
            exit 1
        fi

        # Create symlinks in workspace
        local skill_name=$(basename "$skill")

        # For Claude Code
        mkdir -p "$ws_path/.claude/skills"
        rm -f "$ws_path/.claude/skills/$skill_name" 2>/dev/null
        ln -sf "$skill_source" "$ws_path/.claude/skills/$skill_name"
        echo -e "${GREEN}✓${NC} Created $ws_path/.claude/skills/$skill_name → $skill_source"

        # For Antigravity
        mkdir -p "$ws_path/.agent/skills"
        rm -f "$ws_path/.agent/skills/$skill_name" 2>/dev/null
        ln -sf "$skill_source" "$ws_path/.agent/skills/$skill_name"
        echo -e "${GREEN}✓${NC} Created $ws_path/.agent/skills/$skill_name → $skill_source"

    elif [[ "$target" == "global" ]]; then
        echo -e "${YELLOW}For global sync, use: koda skills sync --global${NC}"
    else
        echo -e "${RED}Error: invalid target format. Use ws:<path> or global${NC}"
        exit 1
    fi
}

cmd_pull() {
    local skill="$1"

    if [ -z "$skill" ]; then
        echo -e "${RED}Error: skill name required${NC}"
        echo "Usage: koda skills pull <namespace/skill>"
        exit 1
    fi

    local skill_source="$SKILLS_DIR/$skill"
    local skill_name=$(basename "$skill")
    local current_dir=$(pwd)

    if [ ! -d "$skill_source" ]; then
        echo -e "${RED}Error: skill '$skill' not found in $SKILLS_DIR${NC}"
        exit 1
    fi

    # Create symlinks in current workspace
    # For Claude Code
    mkdir -p "$current_dir/.claude/skills"
    rm -f "$current_dir/.claude/skills/$skill_name" 2>/dev/null
    ln -sf "$skill_source" "$current_dir/.claude/skills/$skill_name"
    echo -e "${GREEN}✓${NC} Created .claude/skills/$skill_name → $skill_source"

    # For Antigravity
    mkdir -p "$current_dir/.agent/skills"
    rm -f "$current_dir/.agent/skills/$skill_name" 2>/dev/null
    ln -sf "$skill_source" "$current_dir/.agent/skills/$skill_name"
    echo -e "${GREEN}✓${NC} Created .agent/skills/$skill_name → $skill_source"
}

cmd_install() {
    local url="$1"
    local namespace="community"

    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ns|--namespace)
                namespace="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -z "$url" ]; then
        echo -e "${RED}Error: git URL required${NC}"
        echo "Usage: koda skills install <git-url> [--namespace community]"
        exit 1
    fi

    # Extract repo name from URL
    local repo_name=$(basename "$url" .git)
    local target_dir="$SKILLS_DIR/$namespace/$repo_name"

    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}Skill '$repo_name' already exists. Updating...${NC}"
        cd "$target_dir" && git pull
    else
        echo -e "${CYAN}Cloning $url to $namespace/$repo_name...${NC}"
        git clone "$url" "$target_dir"
    fi

    echo -e "${GREEN}✓${NC} Installed $namespace/$repo_name"
    echo -e "Run ${CYAN}koda skills sync --global${NC} to propagate"
}

# Main command router
case "${1:-}" in
    status)
        shift
        cmd_status "$@"
        ;;
    list|ls)
        shift
        cmd_list "$@"
        ;;
    sync)
        shift
        cmd_sync "$@"
        ;;
    push)
        shift
        cmd_push "$@"
        ;;
    pull)
        shift
        cmd_pull "$@"
        ;;
    install)
        shift
        cmd_install "$@"
        ;;
    --help|-h|help|"")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

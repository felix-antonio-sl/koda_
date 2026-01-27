#!/bin/bash
set -e

# KODA Runtime Entrypoint (Federation Enabled)
# Handles syncing of MULTIPLE repositories defined in KODA_REPOS_MAP
# Format: "namespace=url;namespace2=url2"

REPOS_MAP="${KODA_REPOS_MAP:-}"
BRANCH="${KODA_BRANCH:-develop}"
SYNC_INTERVAL="${KODA_SYNC_INTERVAL:-60}"
BASE_DIR="/opt/koda/repos"

echo "🚀 KODA Federation Runtime Starting..."
echo "🌿 Global Branch Strategy: ${BRANCH}"

# Helper function to sync a repo
sync_repo() {
    local ns=$1
    local url=$2
    local target_dir="${BASE_DIR}/${ns}"

    echo "📦 Syncing Namespace: ${ns}..."
    
    if [ ! -d "${target_dir}/.git" ]; then
        echo "  ⬇️  Cloning ${url} -> ${target_dir}..."
        git clone -b "$BRANCH" "$url" "$target_dir"
    else
        echo "  🔄 Updating ${target_dir}..."
        cd "$target_dir"
        git fetch origin "$BRANCH"
        git reset --hard "origin/$BRANCH" # Force strict sync for GitOps
    fi
}

# 1. Initial Sync Loop
if [ -n "$REPOS_MAP" ]; then
    # Split by semicolon
    IFS=';' read -ra REPOS <<< "$REPOS_MAP"
    for repo_def in "${REPOS[@]}"; do
        # Split by equals
        IFS='=' read -r ns url <<< "$repo_def"
        if [[ -n "$ns" && -n "$url" ]]; then
            sync_repo "$ns" "$url"
        fi
    done
else
    echo "⚠️  No KODA_REPOS_MAP defined. Starting empty runtime."
fi

# 2. Inject Production Configuration
if [ -f "/opt/koda/config/resolver.prod.yml" ]; then
    echo "💉 Injecting production resolver to ALL repositories..."
    for dir in "${BASE_DIR}"/*; do
        if [ -d "$dir" ]; then
            echo "  -> Injecting to $(basename "$dir")"
            cp /opt/koda/config/resolver.prod.yml "$dir/.knowledge-resolver.yml"
        fi
    done
fi

# 3. Validation (Check KODA Core)
if [ -d "${BASE_DIR}/koda" ]; then
    echo "🔍 Validating KODA Core..."
    cd "${BASE_DIR}/koda"
    /opt/koda/scripts/koda validate --strict
fi

# 4. Watch Loop
echo "✅ Federation Active. Watching for changes..."

while true; do
    sleep "$SYNC_INTERVAL"
    
    # Re-sync all repos
    if [ -n "$REPOS_MAP" ]; then
        IFS=';' read -ra REPOS <<< "$REPOS_MAP"
        for repo_def in "${REPOS[@]}"; do
            IFS='=' read -r ns url <<< "$repo_def"
            if [[ -n "$ns" && -n "$url" ]]; then
                 # Simple fetch check could go here, for now just force sync logic
                 sync_repo "$ns" "$url" > /dev/null
            fi
        done
        
        # Re-inject config to ensure permanence
        if [ -f "/opt/koda/config/resolver.prod.yml" ]; then
            for dir in "${BASE_DIR}"/*; do
                if [ -d "$dir" ]; then
                    cp /opt/koda/config/resolver.prod.yml "$dir/.knowledge-resolver.yml"
                fi
            done
        fi
    fi
done

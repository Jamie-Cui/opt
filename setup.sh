#!/bin/bash

# set-submodule-proxy.sh
# Read git global proxy settings and apply them to all submodules

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Current directory is not a git repository"
    exit 1
fi

log_info "Starting to set up submodule proxies..."

# Get git global proxy settings
HTTP_PROXY=$(git config --global --get http.proxy 2>/dev/null || echo "")
HTTPS_PROXY=$(git config --global --get https.proxy 2>/dev/null || echo "")

if [[ -z "$HTTP_PROXY" && -z "$HTTPS_PROXY" ]]; then
    log_warn "No git global proxy settings detected"
    echo "Please set git global proxy first:"
    echo "  git config --global http.proxy http://proxy-host:proxy-port"
    echo "  git config --global https.proxy http://proxy-host:proxy-port"
    exit 0
fi

log_info "Detected global proxy settings:"
[[ -n "$HTTP_PROXY" ]] && echo "  HTTP proxy: $HTTP_PROXY"
[[ -n "$HTTPS_PROXY" ]] && echo "  HTTPS proxy: $HTTPS_PROXY"

# Get all submodule paths
log_info "Getting submodule list..."
submodule_paths=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')

if [[ -z "$submodule_paths" ]]; then
    log_warn "No submodules found"
    exit 0
fi

# Statistics variables
total_submodules=0
updated_submodules=0

# Set proxy for each submodule
for submodule_path in $submodule_paths; do
    total_submodules=$((total_submodules + 1))
    
    # Check if submodule directory exists
    if [[ ! -d "$submodule_path" ]]; then
        log_warn "Submodule directory does not exist: $submodule_path, skipping"
        continue
    fi
    
    log_info "Processing submodule: $submodule_path"
    
    # Enter submodule directory
    cd "$submodule_path"
    
    # Check if it's a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warn "$submodule_path is not a valid git repository, skipping"
        cd - > /dev/null
        continue
    fi
    
    # Set proxy
    proxy_updated=false
    
    if [[ -n "$HTTP_PROXY" ]]; then
        current_http_proxy=$(git config --local --get http.proxy 2>/dev/null || echo "")
        if [[ "$current_http_proxy" != "$HTTP_PROXY" ]]; then
            git config http.proxy "$HTTP_PROXY"
            log_info "  Setting HTTP proxy: $HTTP_PROXY"
            proxy_updated=true
        else
            log_info "  HTTP proxy already set correctly"
        fi
    fi
    
    if [[ -n "$HTTPS_PROXY" ]]; then
        current_https_proxy=$(git config --local --get https.proxy 2>/dev/null || echo "")
        if [[ "$current_https_proxy" != "$HTTPS_PROXY" ]]; then
            git config https.proxy "$HTTPS_PROXY"
            log_info "  Setting HTTPS proxy: $HTTPS_PROXY"
            proxy_updated=true
        else
            log_info "  HTTPS proxy already set correctly"
        fi
    fi
    
    if $proxy_updated; then
        updated_submodules=$((updated_submodules + 1))
    fi
    
    # Return to main repository directory
    cd - > /dev/null
done

# Output result summary
echo
log_info "Proxy setup complete!"
echo "Summary:"
echo "  Total submodules: $total_submodules"
echo "  Updated submodules: $updated_submodules"

if [[ $updated_submodules -eq 0 ]]; then
    log_info "All submodule proxy settings are already correct"
else
    log_info "Updated proxy settings for $updated_submodules submodules"
fi

# Optional: Test connection
echo
read -p "Test submodule connection? (y/N): " reply
reply=${reply:-n}
if [[ $reply =~ ^[Yy]$ ]]; then
    log_info "Testing submodule connections..."
    
    for submodule_path in $submodule_paths; do
        if [[ ! -d "$submodule_path" ]]; then
            continue
        fi
        
        echo -n "Testing $submodule_path ... "
        
        cd "$submodule_path"
        if git fetch --dry-run > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗${NC}"
        fi
        cd - > /dev/null
    done
fi

# Optional: Update all submodules
echo
read -p "Update all submodules? (y/N): " reply
reply=${reply:-n}
if [[ $reply =~ ^[Yy]$ ]]; then
    log_info "Updating all submodules..."
    
    if git submodule update --init --recursive; then
        log_info "All submodules updated successfully"
    else
        log_warn "Some submodules failed to update, but continuing..."
    fi
fi

#!/usr/bin/env bash
# ============================================================================
# ZSH Plugin Installer - Universal Git-based plugin management
# ============================================================================
# Usage: zsh-plugin-install [--update]
#
# Installs zsh plugins via git clone into ~/.local/share/zsh/plugins/
# Run with --update to pull latest changes for existing plugins
# ============================================================================

set -e

PLUGIN_DIR="${HOME}/.local/share/zsh/plugins"

# Plugin definitions: name|repo_url
PLUGINS=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for git
if ! command -v git &>/dev/null; then
    error "git is not installed. Please install git first."
    exit 1
fi

# Create plugin directory
mkdir -p "$PLUGIN_DIR"

UPDATE_MODE=false
[[ "$1" == "--update" ]] && UPDATE_MODE=true

info "Plugin directory: $PLUGIN_DIR"
echo ""

for plugin_entry in "${PLUGINS[@]}"; do
    IFS='|' read -r name repo <<< "$plugin_entry"
    plugin_path="${PLUGIN_DIR}/${name}"

    if [[ -d "$plugin_path" ]]; then
        if $UPDATE_MODE; then
            info "Updating ${name}..."
            if git -C "$plugin_path" pull --ff-only 2>/dev/null; then
                success "${name} updated"
            else
                warn "${name} update failed (may have local changes)"
            fi
        else
            success "${name} already installed"
        fi
    else
        info "Installing ${name}..."
        if git clone --depth=1 "$repo" "$plugin_path" 2>/dev/null; then
            success "${name} installed"
        else
            error "Failed to install ${name}"
        fi
    fi
done

echo ""
success "Done! Restart your shell or run: source ~/.zshrc"


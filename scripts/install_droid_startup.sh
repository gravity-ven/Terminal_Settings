#!/bin/bash

# Install Droid Startup Script
# This script installs the Droid startup functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "$SCRIPT_DIR/droid_startup.sh" ]; then
    echo "Error: This script must be run from the Terminal_Settings/scripts directory"
    exit 1
fi

echo "🚀 Installing Droid startup functionality..."

# Create ~/.droid_bin directory
DROID_BIN_DIR="$HOME/.droid_bin"
mkdir -p "$DROID_BIN_DIR"

# Copy scripts to bin directory
cp "$SCRIPT_DIR/droid_startup.sh" "$DROID_BIN_DIR/"
cp "$SCRIPT_DIR/droid_repos_config.sh" "$DROID_BIN_DIR/"
chmod +x "$DROID_BIN_DIR"/*.sh

print_success "Scripts installed to $DROID_BIN_DIR"

# Add to PATH in shell configuration
add_to_shell_config() {
    local shell_config="$1"
    local shell_name="$2"
    
    if [ -f "$shell_config" ]; then
        # Check if DROID_BIN_DIR is already in PATH
        if ! grep -q "$DROID_BIN_DIR" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# Droid startup functionality" >> "$shell_config"
            echo 'export PATH="$HOME/.droid_bin:$PATH"' >> "$shell_config"
            echo '# Run Droid startup script (quiet mode)' >> "$shell_config"
            echo 'droid_startup --quiet' >> "$shell_config"
            
            print_success "Added Droid startup to $shell_name configuration"
            print_warning "Restart your terminal or run 'source $shell_config' to apply changes"
        else
            print_info "Droid already configured in $shell_name"
        fi
    fi
}

# Add to shell configurations
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
    add_to_shell_config "$HOME/.zshrc" "Zsh"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
    add_to_shell_config "$HOME/.bash_profile" "Bash"
else
    print_warning "Could not determine shell type. Manual configuration required:"
    print_info "Add the following to your shell configuration:"
    echo 'export PATH="$HOME/.droid_bin:$PATH"'
    echo 'droid_startup --quiet'
fi

# Create initial configuration
print_info "Creating initial Droid configuration..."
"$DROID_BIN_DIR/droid_repos_config.sh" add "Terminal_Settings" "https://github.com/gravity-ven/Terminal_Settings.git" "\$HOME/.terminal_settings" "main" "scripts/setup_terminal.sh" "Terminal configurations and settings"

echo ""
print_success "🎉 Droid startup installation complete!"
echo ""
echo "📋 What was installed:"
echo "   - droid_startup.sh: Auto-syncs repositories and monitors tokens"
echo "   - droid_repos_config.sh: Manages repository configurations"
echo ""
echo "🔧 Usage:"
echo "   - droid_startup: Run synchronously with verbose output"
echo "   - droid_startup --quiet: Run silently (automatically on shell start)"
echo "   - droid_repos_config: Manage synchronized repositories"
echo ""
print_warning "Remember to restart your terminal for changes to take effect!"

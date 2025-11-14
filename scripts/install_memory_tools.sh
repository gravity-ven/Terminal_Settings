#!/bin/bash

# Install Memory Optimization Tools
# Sets up all memory optimization utilities and scripts

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INSTALL_DIR="$HOME/.local/bin"
readonly CONFIG_DIR="$HOME/.config/memory-tools"

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    local level=$1
    shift
    echo -e "${level} $*"
}

# Create installation directory
create_install_dir() {
    log "${BLUE}[SETUP]" "Creating installation directories"
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # Add to PATH if not already present
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc" 2>/dev/null || true
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bash_profile" 2>/dev/null || true
        log "${BLUE}[SETUP]" "Added $INSTALL_DIR to PATH"
    fi
}

# Install scripts with proper permissions
install_scripts() {
    log "${BLUE}[INSTALL]" "Installing memory and context optimization scripts"
    
    # Copy scripts to install directory
    cp "$SCRIPT_DIR/memory_optimizer.sh" "$INSTALL_DIR/memory_optimizer"
    cp "$SCRIPT_DIR/memory_monitor.zsh" "$INSTALL_DIR/memory_monitor.zsh"
    cp "$SCRIPT_DIR/context_optimizer.sh" "$INSTALL_DIR/context_optimizer"
    cp "$SCRIPT_DIR/check_memory_usage.sh" "$INSTALL_DIR/check_memory_usage"
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/memory_optimizer"
    chmod +x "$INSTALL_DIR/memory_monitor.zsh"
    chmod +x "$INSTALL_DIR/context_optimizer"
    chmod +x "$INSTALL_DIR/check_memory_usage"
    
    log "${GREEN}[SUCCESS]" "Scripts installed to $INSTALL_DIR"
}

# Configure zsh integration
setup_zsh_integration() {
    local zshrc="$HOME/.zshrc"
    
    if [[ -f "$zshrc" ]]; then
        log "${BLUE}[ZSH]" "Setting up ZSH memory and context monitoring"
        
        # Add monitoring integration if not already present
        if ! grep -q "memory_monitor.zsh" "$zshrc" 2>/dev/null; then
            cat >> "$zshrc" << 'EOF'

# Memory and Context engineering integration
if [[ -f "$HOME/.local/bin/memory_monitor.zsh" ]]; then
    source "$HOME/.local/bin/memory_monitor.zsh"
fi

# Initialize context engineering on startup
if command -v context_optimizer >/dev/null 2>&1; then
    # Auto-initialize context systems
    if [[ ! -d "$HOME/.config/context-engineer" ]]; then
        context_optimizer init >/dev/null 2>&1 &
    fi
fi
EOF
            log "${GREEN}[ZSH]" "Added memory and context monitoring to .zshrc"
        fi
    fi
}

# Configure bash integration
setup_bash_integration() {
    local bash_profile="$HOME/.bash_profile"
    
    if [[ -f "$bash_profile" ]]; then
        log "${BLUE}[BASH]" "Setting up Bash memory monitoring"
        
        # Add memory monitoring command for bash
        if ! grep -q "memory_optimizer" "$bash_profile" 2>/dev/null; then
            cat >> "$bash_profile" << 'EOF'

# Memory monitoring commands for bash
alias mem-check='ps -o rss=,pid=,command= | head -10'
alias mem-cleanup='source ~/.local/bin/memory_optimizer'

EOF
            log "${GREEN}[BASH]" "Added memory aliases to .bash_profile"
        fi
    fi
}

# Create systemd user service for auto cleanup (if available)
setup_systemd_service() {
    if command -v systemctl >/dev/null 2>&1 && [[ -d "$HOME/.config/systemd/user" ]]; then
        log "${BLUE}[SYSTEMD]" "Setting up auto-cleanup service"
        
        mkdir -p "$HOME/.config/systemd/user"
        
        cat > "$HOME/.config/systemd/user/memory-cleanup.service" << EOF
[Unit]
Description=Terminal Memory Cleanup
Description=Automatically cleans up terminal memory usage

[Service]
Type=simple
ExecStart=$INSTALL_DIR/memory_optimizer auto
Restart=on-failure
RestartSec=300

[Install]
WantedBy=default.target
EOF
        
        # Enable and start the service
        systemctl --user enable memory-cleanup.service 2>/dev/null || true
        systemctl --user start memory-cleanup.service 2>/dev/null || true
        
        log "${GREEN}[SYSTEMD]" "Auto-cleanup service configured"
    fi
}

# Create cron job for periodic cleanup (alternative to systemd)
setup_cron_job() {
    log "${BLUE}[CRON]" "Setting up periodic cleanup via cron"
    
    local cron_entry="0 */2 * * * $INSTALL_DIR/memory_optimizer optimize >/dev/null 2>&1"
    
    # Add to user crontab if not already present
    if ! crontab -l 2>/dev/null | grep -q "memory_optimizer"; then
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        log "${GREEN}[CRON]" "Added periodic cleanup to crontab (every 2 hours)"
    fi
}

# Create configuration file
create_config() {
    log "${BLUE}[CONFIG]" "Creating default configuration"
    
    cat > "$CONFIG_DIR/config.toml" << 'EOF'
# Terminal Memory Optimization Configuration

[thresholds]
# Memory threshold in MB for shell alerts
shell_threshold_mb = 50
# Memory threshold in MB for terminal alerts  
terminal_threshold_mb = 100
# Total system memory threshold in MB for aggressive cleanup
total_threshold_mb = 10240

[intervals]
# How many commands to run between memory checks
check_interval = 5
# Minutes between automatic cleanup runs
auto_cleanup_minutes = 120

[features]
# Enable automatic memory monitoring
monitoring_enabled = true
# Enable periodic cleanup
auto_cleanup = true
# Enable aggressive cleanup during high system load
aggressive_cleanup_under_load = true

[notifications]
# Show alerts when thresholds exceeded
show_alerts = true
# Show tips for memory reduction
show_tips = true
EOF

    log "${GREEN}[CONFIG]" "Configuration created at $CONFIG_DIR/config.toml"
}

# Install additional utilities
install_extra_tools() {
    log "${BLUE}[TOOLS]" "Setting up memory monitoring tools"
    
    # Create quick commands
    cat > "$INSTALL_DIR/mem-quick-clean" << 'EOF'
#!/bin/bash
# Quick memory cleanup for immediate relief

# Clear shell history if too large
if [[ -f "$HOME/.zsh_history" ]]; then
    tail -n 500 "$HOME/.zsh_history" > "$HOME/.zsh_history.tmp" && mv "$HOME/.zsh_history.tmp" "$HOME/.zsh_history"
fi

# Clean temp files
find /tmp -name "tmux-*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true

echo "Quick cleanup completed. Try 'memory_optimizer optimize' for full optimization."
EOF
    
    chmod +x "$INSTALL_DIR/mem-quick-clean"
    
    log "${GREEN}[TOOLS]" "Additional tools installed"
}

# Show completion message
show_completion() {
    log "${GREEN}[COMPLETE]" "Memory and context optimization tools installation complete!"
    echo
    echo "Memory Commands:"
    echo "  mem-check        - Check current memory usage"
    echo "  mem-cleanup      - Run memory optimization"
    echo "  mem-quick-clean  - Quick cleanup"
    echo "  mem-monitor-on   - Enable monitoring"
    echo "  mem-monitor-off  - Disable monitoring"
    echo "  mem-set-threshold N - Set alert threshold to N MB"
    echo
    echo "Context Engineering Commands:"
    echo "  ctx-optimize     - Optimize current context usage"
    echo "  ctx-status       - Show context status and patterns"
    echo "  ctx-clean        - Clean old context caches"
    echo "  ctx-patterns     - Show pattern learning commands"
    echo "  ctx-learn-success - Record successful context patterns"
    echo
    echo "Configuration: $CONFIG_DIR/config.toml"
    echo "Context systems: $HOME/.config/context-engineer/"
    echo "Scripts installed in: $INSTALL_DIR"
    echo
    echo "To activate: Restart your terminal or run 'source ~/.zshrc'"
}

# Main installation
main() {
    log "${BLUE}[START]" "Installing terminal memory optimization tools"
    
    create_install_dir
    install_scripts
    setup_zsh_integration  
    setup_bash_integration
    setup_systemd_service
    setup_cron_job
    create_config
    install_extra_tools
    show_completion
    
    log "${GREEN}[SUCCESS]" "Installation completed successfully"
}

# Run installation
main "$@"

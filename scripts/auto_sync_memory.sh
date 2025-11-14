#!/bin/bash

# Auto-Sync Memory Optimizations Script
# Automatically syncs memory optimization changes to GitHub
# Designed to be run periodically via cron or systemd timer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMINAL_SETTINGS_DIR="$(dirname "$SCRIPT_DIR")"
SYNC_SCRIPT="$SCRIPT_DIR/sync_settings.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log() {
    local level=$1
    shift
    local timestamp=$(date '+%H:%M:%S')
    echo -e "${level} [${timestamp}] $*"
}

# Check if there are memory optimization changes to sync
check_memory_changes() {
    cd "$TERMINAL_SETTINGS_DIR"
    
    # Check for any changes in memory-related files
    local memory_files=(
        "zsh/.zshrc"
        "bash/.bash_profile"
        "tmux/.tmux.conf"
        "alacritty/alacritty.yml"
        "alacritty/alacritty.toml"
        "ghostty/config"
        "wezterm/wezterm.lua"
        "scripts/memory_optimizer.sh"
        "scripts/memory_monitor.zsh"
        "scripts/install_memory_tools.sh"
    )
    
    local has_changes=false
    
    for file in "${memory_files[@]}"; do
        if git status --porcelain | grep -q "$file"; then
            log "${YELLOW}[DETECTED]" "Memory optimization changes in $file"
            has_changes=true
        fi
    done
    
    return $([[ "$has_changes" == true ]] && echo 0 || echo 1)
}

# Check if auto-sync is enabled
is_auto_sync_enabled() {
    local config_file="$HOME/.config/memory-tools/config.toml"
    
    if [[ -f "$config_file" ]]; then
        # Check if auto_sync is enabled in config (basic TOML parsing)
        if grep -q 'auto_sync = true' "$config_file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    fi
    
    # Default to enabled if config doesn't exist
    return 0
}

# Check if we're on a network connection
check_network() {
    # Simple network check - try to ping GitHub
    if ping -c 1 -W 5 github.com >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Quiet sync mode for automated runs
quiet_sync() {
    log "${BLUE}[SYNC]" "Starting quiet auto-sync of memory optimizations"
    
    # Check prerequisites
    if ! check_network; then
        log "${YELLOW}[SKIP]" "No network connection, skipping sync"
        return 0
    fi
    
    if ! is_auto_sync_enabled; then
        log "${BLUE}[SKIP]" "Auto-sync disabled in configuration"
        return 0
    fi
    
    if ! check_memory_changes; then
        log "${BLUE}[SKIP]" "No memory optimization changes to sync"
        return 0
    fi
    
    # Run sync in quiet mode
    if [[ -x "$SYNC_SCRIPT" ]]; then
        echo "y" | "$SYNC_SCRIPT" >/dev/null 2>&1 || {
            log "${YELLOW}[SYNC]" "Sync completed with some issues"
        }
        log "${GREEN}[SUCCESS]" "Memory optimizations synced to GitHub"
    else
        log "${YELLOW}[WARNING]" "Sync script not executable: $SYNC_SCRIPT"
    fi
}

# Verbose sync mode for manual runs
verbose_sync() {
    log "${BLUE}[MANUAL]" "Starting manual sync of memory optimizations"
    
    if ! check_network; then
        log "${RED}[ERROR]" "No network connection available"
        return 1
    fi
    
    # Check for changes and sync
    if check_memory_changes; then
        log "${GREEN}[INFO]" "Memory optimization changes detected, syncing..."
        
        if [[ -x "$SYNC_SCRIPT" ]]; then
            "$SYNC_SCRIPT"
        else
            log "${RED}[ERROR]" "Sync script not found or executable: $SYNC_SCRIPT"
            return 1
        fi
    else
        log "${BLUE}[INFO]" "No memory optimization changes to sync"
    fi
}

# Setup periodic sync (cron job)
setup_cron_sync() {
    local cron_entry="*/30 * * * * $0 quiet >/dev/null 2>&1"
    
    log "${BLUE}[CRON]" "Setting up periodic sync every 30 minutes"
    
    # Add to user crontab if not already present
    if ! crontab -l 2>/dev/null | grep -q "auto_sync_memory.sh"; then
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        log "${GREEN}[SUCCESS]" "Auto-sync job added to crontab (every 30 minutes)"
    else
        log "${BLUE}[INFO]" "Auto-sync job already exists in crontab"
    fi
}

# Setup systemd timer (if available)
setup_systemd_timer() {
    if ! command -v systemctl >/dev/null 2>&1; then
        log "${YELLOW}[SKIP]" "systemd not available, skipping timer setup"
        return 0
    fi
    
    if [[ ! -d "$HOME/.config/systemd/user" ]]; then
        log "${YELLOW}[SKIP]" "systemd user directory not found"
        return 0
    fi
    
    log "${BLUE}[SYSTEMD]" "Setting up systemd timer for memory sync"
    
    # Create the service file
    cat > "$HOME/.config/systemd/user/memory-sync.service" << EOF
[Unit]
Description=Auto-sync terminal memory optimizations to GitHub

[Service]
Type=oneshot
ExecStart=$0 quiet
WorkingDirectory=$TERMINAL_SETTINGS_DIR

[Install]
WantedBy=default.target
EOF

    # Create the timer file
    cat > "$HOME/.config/systemd/user/memory-sync.timer" << EOF
[Unit]
Description=Run memory optimization sync every 30 minutes

[Timer]
OnCalendar=*:0/30
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Reload systemd and enable the timer
    systemctl --user daemon-reload || true
    systemctl --user enable memory-sync.timer || true
    systemctl --user start memory-sync.timer || true
    
    log "${GREEN}[SUCCESS]" "Systemd timer configured for 30-minute intervals"
}

# Show current sync status
show_status() {
    cd "$TERMINAL_SETTINGS_DIR"
    
    log "${BLUE}[STATUS]" "Memory optimization sync status"
    echo
    
    # Git status
    echo "Git Repository Status:"
    git status --porcelain | head -5
    echo
    
    # Last sync time (from git log)
    echo "Last Sync Activity:"
    git log --oneline --grep="memory" -n 3 2>/dev/null || echo "No memory-related commits found"
    echo
    
    # Network status
    if check_network; then
        log "${GREEN}[NETWORK]" "Connected to GitHub"
    else
        log "${RED}[NETWORK]" "No network connection"
    fi
    
    # Auto-sync status
    if is_auto_sync_enabled; then
        log "${GREEN}[AUTO-SYNC]" "Enabled"
    else
        log "${YELLOW}[AUTO-SYNC]" "Disabled"
    fi
}

# Main execution based on argument
case "${1:-quiet}" in
    "quiet")
        quiet_sync
        ;;
    "verbose")
        verbose_sync
        ;;
    "setup-cron")
        setup_cron_sync
        ;;
    "setup-systemd")
        setup_systemd_timer
        ;;
    "status")
        show_status
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 {quiet|verbose|setup-cron|setup-systemd|status|help}"
        echo "  quiet       - Quiet auto-sync (default, for automated runs)"
        echo "  verbose     - Verbose sync (for manual runs)"
        echo "  setup-cron  - Setup cron job for periodic sync"
        echo "  setup-systemd - Setup systemd timer for periodic sync"
        echo "  status      - Show current sync status"
        echo "  help        - Show this help message"
        ;;
    *)
        log "${RED}[ERROR]" "Unknown argument: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

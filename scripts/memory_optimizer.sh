#!/bin/bash

# Terminal Memory Optimizer
# Optimizes memory usage across terminal applications and shells

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Memory thresholds (in KB)
readonly SHELL_THRESHOLD=50000
readonly TERMINAL_THRESHOLD=100000
readonly TOTAL_THRESHOLD=10485760  # 10GB in KB

# Logging function
log() {
    local level=$1
    shift
    local timestamp=$(date '+%H:%M:%S')
    echo -e "${timestamp} [${level}] $*"
}

# Check memory usage for a process
check_process_memory() {
    local process_name=$1
    local threshold=$2
    
    local total_mem=0
    local count=0
    
    while IFS= read -r pid; do
        if [[ -n "$pid" && "$pid" != "$$" ]]; then
            local mem_usage=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
            if [[ -n "$mem_usage" && "$mem_usage" =~ ^[0-9]+$ ]]; then
                total_mem=$((total_mem + mem_usage))
                count=$((count + 1))
                
                if [[ "$mem_usage" -gt "$threshold" ]]; then
                    log "${RED}ALERT" "$process_name PID $pid using ${mem_usage}KB (threshold: ${threshold}KB)"
                    ps -o pid= -p "$pid" | xargs -I{} kill -USR1 {} 2>/dev/null || true
                fi
            fi
        fi
    done < <(pgrep "$process_name" || true)
    
    if [[ "$count" -gt 0 ]]; then
        log "${BLUE}INFO" "$process_name: $count processes, total ${total_mem}KB memory"
    fi
    
    return "$total_mem"
}

# Clean up shell history and cache
cleanup_shell_cache() {
    local shell_name=$1
    local history_file=$2
    
    log "${GREEN}CLEANUP" "Cleaning up $shell_name cache and history"
    
    # Clean history if too large
    if [[ -f "$history_file" ]]; then
        local history_size=$(wc -l < "$history_file" 2>/dev/null || echo 0)
        if [[ "$history_size" -gt 2000 ]]; then
            # Keep last 1000 lines
            tail -n 1000 "$history_file" > "$history_file.tmp" && mv "$history_file.tmp" "$history_file"
            log "${GREEN}CLEANUP" "Trimmed $shell_name history from $history_size to 1000 lines"
        fi
    fi
    
    # Clean zsh completion cache
    if [[ "$shell_name" == "zsh" ]]; then
        local cache_dir="$HOME/.cache/zsh"
        if [[ -d "$cache_dir" ]]; then
            find "$cache_dir" -type f -name "*.zwc" -mtime +7 -delete 2>/dev/null || true
            log "${GREEN}CLEANUP" "Cleaned old zsh completion dump files"
        fi
    fi
    
    # Clean bash completion cache (if exists)
    if [[ "$shell_name" == "bash" ]]; then
        local bash_cache="$HOME/.bash_completion.d"
        if [[ -d "$bash_cache" ]]; then
            find "$bash_cache" -name "*.cache" -mtime +7 -delete 2>/dev/null || true
            log "${GREEN}CLEANUP" "Cleaned old bash completion cache"
        fi
    fi
}

# Optimize terminal configuration
optimize_terminal_config() {
    local terminal=$1
    local config_file=$2
    
    log "${GREEN}OPTIMIZE" "Optimizing $terminal configuration"
    
    case "$terminal" in
        "alacritty")
            if [[ -f "$config_file" ]]; then
                sed -i.bak 's/history: [0-9]*/history: 5000/' "$config_file" || true
                sed -i.bak 's/save_to_clipboard: true/save_to_clipboard: false/' "$config_file" || true
                log "${GREEN}OPTIMIZE" "Optimized Alacritty scrollback and clipboard settings"
            fi
            ;;
        "ghostty")
            if [[ -f "$config_file" ]]; then
                sed -i.bak 's/scrollback-limit = [0-9]*/scrollback-limit = 5000/' "$config_file" || true
                log "${GREEN}OPTIMIZE" "Optimized Ghostty scrollback limit"
            fi
            ;;
        "wezterm")
            if [[ -f "$config_file" ]]; then
                sed -i.bak 's/scrollback_lines = [0-9]*/scrollback_lines = 5000/' "$config_file" || true
                log "${GREEN}OPTIMIZE" "Optimized WezTerm scrollback limit"
            fi
            ;;
        "tmux")
            if [[ -f "$config_file" ]]; then
                sed -i.bak 's/history-limit [0-9]*/history-limit 10000/' "$config_file" || true
                sed -i.bak 's/set -g status-interval [0-9]*/set -g status-interval 30/' "$config_file" || true
                log "${GREEN}OPTIMIZE" "Optimized tmux history and status update intervals"
            fi
            ;;
    esac
}

# Clean up temporary files
cleanup_temp_files() {
    log "${GREEN}CLEANUP" "Cleaning up temporary files"
    
    # Clean common temp directories
    find /tmp -name "tmux-*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true
    find /tmp -name "vite-*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true
    find /tmp -name "node-*" -user "$(whoami)" -mtime +1 -delete 2>/dev/null || true
    find "$HOME/.cache" -type f -mtime +7 -delete 2>/dev/null || true
    
    log "${GREEN}CLEANUP" "Completed temporary file cleanup"
}

# Monitor and optimize based on system load
optimize_system_resources() {
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',' || echo "0")
    local load_threshold=2.0
    
    if (( $(echo "$load_avg > $load_threshold" | bc -l) )); then
        log "${YELLOW}SYSTEM" "High system load detected: $load_avg"
        log "${YELLOW}SYSTEM" "Aggressively cleaning up memory resources"
        
        # Kill old processes that might be consuming memory
        ps aux | grep -E '(zsh|bash|alacritty|ghostty|wezterm)' | awk '{print $2,$11}' | while read pid cmd; do
            if [[ -n "$pid" && "$pid" != "$$" ]]; then
                local mem_usage=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ' || echo "0")
                if [[ "$mem_usage" -gt "$TERMINAL_THRESHOLD" ]]; then
                    log "${RED}KILLING" "Large process: $cmd [PID $pid] using ${mem_usage}KB"
                    kill -TERM "$pid" 2>/dev/null || true
                fi
            fi
        done
    fi
}

# Main optimization function
optimize_memory() {
    log "${BLUE}START" "Starting terminal memory optimization"
    
    # Check and optimize shells
    log "${BLUE}SHELLS" "Checking shell memory usage"
    check_process_memory "zsh" "$SHELL_THRESHOLD"
    check_process_memory "bash" "$SHELL_THRESHOLD"
    
    # Cleanup shell caches
    cleanup_shell_cache "zsh" "$HOME/.zsh_history"
    cleanup_shell_cache "bash" "$HOME/.bash_history"
    
    # Check terminal processes
    log "${BLUE}TERMINALS" "Checking terminal process memory"
    check_process_memory "alacritty" "$TERMINAL_THRESHOLD"
    check_process_memory "ghostty" "$TERMINAL_THRESHOLD"
    check_process_memory "wezterm" "$TERMINAL_THRESHOLD"
    check_process_memory "tmux" "$TERMINAL_THRESHOLD"
    
    # Optimize configurations
    optimize_terminal_config "alacritty" "$HOME/.config/alacritty/alacritty.yml"
    optimize_terminal_config "ghostty" "$HOME/.config/ghostty/config"
    optimize_terminal_config "wezterm" "$HOME/.config/wezterm/wezterm.lua"
    optimize_terminal_config "tmux" "$HOME/.tmux.conf"
    
    # System optimizations
    cleanup_temp_files
    optimize_system_resources
    
    # Final memory check
    local total_memory=$(ps -o rss= -p $$ | tr -d ' ')
    log "${BLUE}COMPLETE" "Optimization complete. Current shell memory: ${total_memory}KB"
    
    if [[ "$total_memory" -gt "$SHELL_THRESHOLD" ]]; then
        log "${YELLOW}WARNING" "Shell memory still high: ${total_memory}KB. Consider restarting terminal."
    fi
}

# Auto-cleanup function to run periodically
auto_cleanup() {
    # Run optimization every hour
    while true; do
        optimize_memory
        sleep 3600  # Wait 1 hour
    done
}

# Signal handler for cleanup
cleanup() {
    log "${BLUE}EXIT" "Cleaning up and exiting"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Main execution
case "${1:-optimize}" in
    "optimize")
        optimize_memory
        ;;
    "auto")
        log "${BLUE}AUTO" "Starting automatic memory cleanup"
        auto_cleanup
        ;;
    "check")
        check_process_memory "zsh" "$SHELL_THRESHOLD"
        check_process_memory "bash" "$SHELL_THRESHOLD"
        ;;
    "clean-shell")
        cleanup_shell_cache "zsh" "$HOME/.zsh_history"
        cleanup_shell_cache "bash" "$HOME/.bash_history"
        ;;
    *)
        echo "Usage: $0 {optimize|auto|check|clean-shell}"
        echo "  optimize  - Run full memory optimization (default)"
        echo "  auto      - Run periodic automatic cleanup"
        echo "  check     - Check shell memory usage only"
        echo "  clean-shell - Clean shell history and cache only"
        exit 1
        ;;
esac

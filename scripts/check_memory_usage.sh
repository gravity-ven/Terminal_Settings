#!/bin/bash

# Check Memory Usage Script
# Shows exactly what memory optimization processes are running

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    local level=$1
    shift
    echo -e "${level} $*"
}

# Check what memory optimization scripts are currently running
check_running_processes() {
    log "${BLUE}[PROCESSES]" "Checking memory optimization processes..."
    echo
    
    local processes_found=false
    
    # Check for memory_optimizer processes
    if pgrep -f "memory_optimizer" >/dev/null 2>&1; then
        log "${YELLOW}[RUNNING]" "Memory Optimizer processes:"
        ps aux | grep "memory_optimizer" | grep -v grep | while IFS= read -r line; do
            echo "  $line"
        done
        processes_found=true
    fi
    
    # Check for auto_sync_memory processes
    if pgrep -f "auto_sync_memory" >/dev/null 2>&1; then
        log "${YELLOW}[RUNNING]" "Auto Sync processes:"
        ps aux | grep "auto_sync_memory" | grep -v grep | while IFS= read -r line; do
            echo "  $line"
        done
        processes_found=true
    fi
    
    # Check for memory_monitor (might be hard to detect as it's a function)
    log "${BLUE}[MONITOR]" "Memory Monitor is active in ZSH (runs before each prompt)"
    
    if [[ "$processes_found" != true ]]; then
        log "${GREEN}[IDLE]" "No background optimization processes currently running"
    fi
    echo
}

# Show memory usage by terminal applications
show_terminal_memory() {
    log "${BLUE}[MEMORY]" "Terminal application memory usage:"
    echo
    
    # Check shell processes
    echo "Shell Processes:"
    ps aux | grep -E "(zsh|bash)" | grep -v grep | head -5 | while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local mem=$(echo "$line" | awk '{print $4}')
        local rss=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
        echo "  PID $pid: ${mem}% (${rss:-0}KB) - $line"
    done
    echo
    
    # Check terminal emulators
    echo "Terminal Emulators:"
    ps aux | grep -E "(alacritty|ghostty|wezterm)" | grep -v grep | while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local mem=$(echo "$line" | awk '{print $4}')
        local rss=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
        echo "  PID $pid: ${mem}% (${rss:-0}KB) - $line"
    done
    echo
    
    # Check tmux
    if pgrep tmux >/dev/null 2>&1; then
        echo "TMUX Sessions:"
        pgrep tmux | while read -r pid; do
            local mem=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ')
            local rss=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
            echo "  PID $pid: ${mem}% (${rss}KB)"
        done
        echo
    fi
}

# Check scheduled tasks (cron jobs, systemd timers)
check_scheduled_tasks() {
    log "${BLUE}[SCHEDULED]" "Checking scheduled optimization tasks..."
    echo
    
    # Check crontab
    if crontab -l 2>/dev/null | grep -q "memory"; then
        log "${YELLOW}[CRON]" "Found memory optimization in crontab:"
        crontab -l 2>/dev/null | grep "memory" | sed 's/^/  /'
    else
        log "${GREEN}[CRON]" "No memory optimization cron jobs found"
    fi
    echo
    
    # Check systemd timers (if available)
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl --user list-timers 2>/dev/null | grep -q "memory"; then
            log "${YELLOW}[SYSTEMD]" "Found memory optimization timers:"
            systemctl --user list-timers --no-pager 2>/dev/null | grep "memory" | sed 's/^/  /'
        else
            log "${GREEN}[SYSTEMD]" "No memory optimization systemd timers found"
        fi
    else
        log "${BLUE}[SYSTEMD]" "systemd not available on this system"
    fi
    echo
}

# Show configuration status
check_config_status() {
    log "${BLUE}[CONFIG]" "Memory optimization configuration:"
    echo
    
    local config_file="$HOME/.config/memory-tools/config.toml"
    if [[ -f "$config_file" ]]; then
        log "${GREEN}[CONFIG]" "Configuration file found: $config_file"
        
        # Parse a few key settings
        if grep -q "auto_sync = true" "$config_file" 2>/dev/null; then
            log "${GREEN}[CONFIG]" "Auto-sync: ENABLED"
        else
            log "${YELLOW}[CONFIG]" "Auto-sync: DISABLED"
        fi
        
        if grep -q "monitoring_enabled = true" "$config_file" 2>/dev/null; then
            log "${GREEN}[CONFIG]" "Monitoring: ENABLED"
        else
            log "${YELLOW}[CONFIG]" "Monitoring: DISABLED"
        fi
    else
        log "${YELLOW}[CONFIG]" "Configuration file not found"
    fi
    echo
}

# Show system resource usage
show_system_status() {
    log "${BLUE}[SYSTEM]" "System resource usage:"
    echo
    
    # CPU and memory
    echo "System Resources:"
    local cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%' || echo "N/A")
    local used_mem=$(top -l 1 | grep "PhysMem" | awk '{print $2}' || echo "N/A")
    local free_mem=$(top -l 1 | grep "PhysMem" | awk '{print $6}' || echo "N/A")
    echo "  CPU Usage: ${cpu}%"
    echo "  Memory: ${used_mem} used, ${free_mem} free"
    echo
}

# Show recommendations
show_recommendations() {
    log "${BLUE}[RECOMMENDATIONS]" "Memory optimization status and recommendations:"
    echo
    
    # Check current shell memory
    local shell_mem_kb=$(ps -o rss= -p $$ | tr -d ' ' || echo "0")
    local shell_mem_mb=$(( shell_mem_kb / 1024 ))
    
    if (( shell_mem_mb > 50 )); then
        log "${YELLOW}[ACTION]" "Shell memory high (${shell_mem_mb}MB) - run 'mem-cleanup'"
    elif (( shell_mem_mb > 30 )); then
        log "${BLUE}[INFO]" "Shell memory moderate (${shell_mem_mb}MB) - monitoring"
    else
        log "${GREEN}[GOOD]" "Shell memory optimal (${shell_mem_mb}MB)"
    fi
    
    # Check if background processes are running
    if pgrep -f "memory_optimizer" >/dev/null 2>&1; then
        log "${YELLOW}[INFO]" "Optimization running - wait for completion"
    fi
    
    echo
    log "${BLUE}[COMMANDS]" "Available commands:"
    echo "  mem-check           - Check current memory usage"
    echo "  mem-cleanup         - Run memory optimization"
    echo "  mem-quick-clean     - Quick cleanup"
    echo "  mem-monitor-on/off  - Enable/disable monitoring"
    echo "  auto_sync_memory status - Check sync status"
    echo
}

# Main function
main() {
    log "${GREEN}[STATUS]" "Memory Optimization Status Check"
    echo "=================================================="
    echo
    
    check_running_processes
    show_terminal_memory
    check_scheduled_tasks
    check_config_status
    show_system_status
    show_recommendations
}

case "${1:-}" in
    "help"|"-h"|"--help")
        echo "Usage: $0 [help]"
        echo "Shows current memory optimization status and running processes"
        ;;
    *)
        main
        ;;
esac

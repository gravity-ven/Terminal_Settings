#!/usr/bin/env zsh

# Memory Monitor ZSH Function
# Monitors and alerts on high memory usage in zsh

# Configuration
typeset -g MEMORY_MONITOR_ENABLED=true
typeset -g MEMORY_THRESHOLD_MB=50  # Alert at 50MB
typeset -g MEMORY_CHECK_INTERVAL=5  # Check every 5 commands

# Internal counter
typeset -gi MEMORY_MONITOR_COUNT=0

# Memory monitoring function
memory_monitor() {
    [[ "$MEMORY_MONITOR_ENABLED" != true ]] && return
    
    # Increment counter and check if we should monitor this time
    (( MEMORY_MONITOR_COUNT++ ))
    (( MEMORY_MONITOR_COUNT % MEMORY_CHECK_INTERVAL != 0 )) && return
    
    # Get current shell memory usage in MB
    local mem_kb=$(ps -o rss= -p $$ | tr -d ' ' || echo "0")
    local mem_mb=$(( mem_kb / 1024 ))
    
    # Check threshold and warn if exceeded
    if (( mem_mb > MEMORY_THRESHOLD_MB )); then
        echo -e "\033[38;5;208m⚠️  Memory Alert: Shell using ${mem_kb}KB (${mem_mb}MB) (threshold: ${MEMORY_THRESHOLD_MB}MB)\033[0m"
        echo -e "\033[38;5;208m💡 Tip: Run 'mem-cleanup' or restart terminal\033[0m"
    fi
    
    # Check background processes (non-blocking)
    local bg_processes=$(ps aux | grep -E "(memory_optimizer|auto_sync_memory)" | grep -v grep | wc -l || echo "0")
    if (( bg_processes > 2 )); then
        echo -e "\033[38;5;4mℹ️  ${bg_processes} memory processes running\033[0m"
    fi
    
    # Advanced: check for large zsh history
    local history_file="$HOME/.zsh_history"
    if [[ -f "$history_file" ]]; then
        local history_lines=$(wc -l < "$history_file" 2>/dev/null || echo "0")
        if (( history_lines > 10000 )); then
            echo -e "\033[38;5;208m📝 History file large: ${history_lines} lines\033[0m"
        fi
    fi
}

# Add to zsh precmd to run before each prompt
if ! [[ $precmd_functions =~ memory_monitor ]]; then
    precmd_functions+=("memory_monitor")
fi

# Manual command to check memory
alias mem-check='ps -o rss=,pid=,command= | head -10'

# Auto-cleanup command
alias mem-cleanup='source ~/.local/bin/memory_optimizer.sh'

# Disable memory monitoring
alias mem-monitor-off='MEMORY_MONITOR_ENABLED=false'

# Enable memory monitoring
alias mem-monitor-on='MEMORY_MONITOR_ENABLED=true'

# Set threshold
mem-set-threshold() {
    local new_threshold=$1
    if [[ -n "$new_threshold" && "$new_threshold" =~ ^[0-9]+$ ]]; then
        MEMORY_THRESHOLD_MB="$new_threshold"
        echo "Memory alert threshold set to ${new_threshold}MB"
    else
        echo "Usage: mem-set-threshold <MB>"
        echo "Current threshold: ${MEMORY_THRESHOLD_MB}MB"
    fi
}

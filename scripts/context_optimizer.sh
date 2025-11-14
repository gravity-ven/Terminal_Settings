#!/bin/bash

# Context Engineering Terminal Optimizer
# Integrates Anthropic's context engineering principles into terminal operations

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$HOME/.config/context-engineer"
readonly MEMORY_SYSTEMS_DIR="$CONFIG_DIR/memory-systems"

# Colors for output
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

# Initialize context engineering infrastructure
init_context_infrastructure() {
    log "${BLUE}[INIT]" "Setting up context engineering infrastructure..."
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$MEMORY_SYSTEMS_DIR"
    mkdir -p "$MEMORY_SYSTEMS_DIR/patterns"
    mkdir -p "$MEMORY_SYSTEMS_DIR/context-cache"
    mkdir -p "$MEMORY_SYSTEMS_DIR/learning-logs"
    
    log "${GREEN}[SUCCESS]" "Context infrastructure initialized"
}

# Create project context memory system
create_project_memory() {
    local project_dir="${1:-$(pwd)}"
    local memory_file="$project_dir/.context-memory.md"
    
    log "${BLUE}[MEMORY]" "Creating project context memory system..."
    
    cat > "$memory_file" << 'EOF'
# Project Context Memory

## Context Retrieval Patterns

### High-Signal Context Sources
- CLAUDE.md: Core project knowledge and workflows
- AGENTS.md: Custom droid patterns and behaviors  
- README.md: Project overview and setup instructions
- package.json/pyproject.toml: Dependencies and scripts
- src/ or lib/: Core implementation files
- tests/ or test/: Test patterns and examples

### Context Affinity Groups
Files that benefit from being together in context:
1. **Configuration Group**: package.json, tsconfig.json, .env files
2. **Documentation Group**: README.md, docs/, CLAUDE.md
3. **Core Logic Group**: Main implementation files in primary directories
4. **Test Group**: Test files, test configs, testing utilities

## Just-in-Time Retrieval Rules

### Progressive Disclosure Strategy
1. Start with user request context only
2. Add project metadata (CLAUDE.md) if request is project-specific
3. Include relevant file groups based on task classification
4. Expand context only when necessary, never proactively

### Context Budget Allocation
- Core request: 25% of context window
- Project knowledge: 20% (CLAUDE.md, AGENTS.md)
- Active workspace: 35% (relevant files only)
- Memory patterns: 15% (learned strategies)
- Safety margin: 5%

## Learning Patterns

### Successful Context Combinations
*(Automatically populated by context optimizer)*

- [Pattern]: Task classification + project metadata + relevant file group
- [Pattern]: Error analysis + diagnostics + fix patterns
- [Pattern]: Code generation + examples + style guidelines

### Context Rot Prevention
- Tool results cleared after processing
- Redundant file contents removed
- Summary preservation over raw data
- Recent interactions prioritized over historical

## Optimization Triggers
- Context window > 80% full → initiate compaction
- Task completion failures → expand context scope
- Successful completions → pattern storage
- Error patterns → context adjustment

---

This file is automatically maintained by the context optimizer.
Last updated: $(date)
EOF

    log "${GREEN}[SUCCESS]" "Project memory system created: $memory_file"
}

# Configure terminal context awareness
configure_terminal_context() {
    local shell_config="$HOME/.zshrc"
    
    log "${BLUE}[CONFIGURE]" "Setting up terminal context awareness..."
    
    # Add context engineering tools to shell
    cat >> "$shell_config" << 'EOF'

# Context Engineering Integration
if [[ -f "$HOME/.local/bin/context_monitor.zsh" ]]; then
    source "$HOME/.local/bin/context_monitor.zsh"
fi

# Context optimization commands
alias ctx-optimize='context_optimizer optimize'
alias ctx-status='context_optimizer status'
alias ctx-clean='context_optimizer clean'
alias ctx-learn='context_optimizer learn'
alias ctx-patterns='context_optimizer patterns'

# Context budget monitoring
ctx-budget-alert() {
    local context_usage=$(ps -o rss= -p $$ | tr -d ' ' 2>/dev/null || echo "0")
    local threshold=50000  # 50KB shell memory threshold
    
    if [[ "$context_usage" -gt "$threshold" ]]; then
        echo "⚠️  Context budget high: ${context_usage}KB - run ctx-optimize"
    fi
}

# Run before each command (lightweight check)
preexec() {
    ctx-budget-alert
}
EOF

    log "${GREEN}[SUCCESS]" "Terminal context awareness configured"
}

# Create context monitoring system
create_context_monitor() {
    local monitor_script="$HOME/.local/bin/context_monitor.zsh"
    
    log "${BLUE}[MONITOR]" "Creating context monitoring system..."
    
    cat > "$monitor_script" << 'EOF'
#!/usr/bin/env zsh

# Context Engineering Monitor for Terminal Sessions

# Configuration
typeset -g CONTEXT_MONITOR_ENABLED=true
typeset -g CONTEXT_BUDGET_KB=50000    # 50MB memory equivalent
typeset -g CONTEXT_TRIGGER_INTERVAL=3  # Check every 3 commands

# Internal state
typeset -gi CONTEXT_MONITOR_COUNT=0
typeset -g CONTEXT_PATTERNS_DIR="$HOME/.config/context-engineer/patterns"

# Context analysis function
context_analyze() {
    [[ "$CONTEXT_MONITOR_ENABLED" != true ]] && return
    
    # Check interval
    (( CONTEXT_MONITOR_COUNT++ ))
    (( CONTEXT_MONITOR_COUNT % CONTEXT_TRIGGER_INTERVAL != 0 )) && return
    
    # Current context usage
    local current_kb=$(ps -o rss= -p $$ | tr -d ' ' || echo "0")
    local context_ratio=$(( current_kb * 100 / CONTEXT_BUDGET_KB ))
    
    # Alert if approaching context budget
    if (( context_ratio > 80 )); then
        echo -e "\033[38;5;208m⚡ Context: ${context_ratio}% (${current_kb}KB) - Consider ctx-optimize\033[0m"
    elif (( context_ratio > 60 )); then
        echo -e "\033[38;5;4mℹ️  Context: ${context_ratio}% (${current_kb}KB)\033[0m"
    fi
    
    # Suggest patterns if available
    local current_dir=$(basename "$PWD")
    local pattern_file="$CONTEXT_PATTERNS_DIR/${current_dir}_patterns.md"
    
    if [[ -f "$pattern_file" && "$CONTEXT_MONITOR_COUNT" -gt 10 ]]; then
        echo -e "\033[38;5;2m💡 Context patterns available: ctx-patterns\033[0m"
    fi
}

# Learning function for context patterns
context_learn_pattern() {
    local task_type="$1"
    local context_summary="$2"
    local outcome="$3"
    
    local pattern_file="$CONTEXT_PATTERNS_DIR/${(%)PWD}_patterns.md"
    mkdir -p "$CONTEXT_PATTERNS_DIR"
    
    # Create pattern file if doesn't exist
    if [[ ! -f "$pattern_file" ]]; then
        cat > "$pattern_file" << EOF
# Context Patterns for ${(%)PWD}

## Successful Patterns

EOF
    fi
    
    # Add successful pattern
    if [[ "$outcome" == "success" ]]; then
        cat >> "$pattern_file" << EOF

### $(date '+%Y-%m-%d %H:%M')
**Task**: $task_type
**Context**: $context_summary
**Result**: Successful
EOF
    fi
    
    echo "Pattern learned for $task_type"
}

# Add to prompt execution
if ! [[ $precmd_functions =~ context_analyze ]]; then
    precmd_functions+=("context_analyze")
fi

# Pattern learning commands
alias ctx-learn-success='context_learn_pattern $1 $2 "success"'
alias ctx-patterns-view="cat $CONTEXT_PATTERNS_DIR/\${(%)PWD}_patterns.md 2>/dev/null || echo 'No patterns yet'"

echo "Context engineering monitor loaded"
EOF

    chmod +x "$monitor_script"
    log "${GREEN}[SUCCESS]" "Context monitor created: $monitor_script"
}

# Context optimization script
optimize_context() {
    log "${BLUE}[OPTIMIZE]" "Running context optimization..."
    
    # Clear duplicate path entries
    typeset -U path
    export PATH
    
    # Clean shell history if too large
    local history_file="$HOME/.zsh_history"
    if [[ -f "$history_file" ]]; then
        local history_lines=$(wc -l < "$history_file" 2>/dev/null || echo "0")
        if [[ "$history_lines" -gt 5000 ]]; then
            tail -n 2000 "$history_file" > "$history_file.bak" && mv "$history_file.bak" "$history_file"
            log "${GREEN}[CLEANUP]" "History trimmed from $history_lines to 2000 lines"
        fi
    fi
    
    # Clear temporary caches
    local cache_dir="$MEMORY_SYSTEMS_DIR/context-cache"
    find "$cache_dir" -name "*.tmp" -mtime +1 -delete 2>/dev/null || true
    
    # Check context usage
    local current_kb=$(ps -o rss= -p $$ | tr -d ' ' || echo "0")
    log "${GREEN}[STATUS]" "Context usage: ${current_kb}KB"
    
    # Suggest next actions
    if [[ "$current_kb" -gt "$CONTEXT_BUDGET_KB" ]]; then
        log "${YELLOW}[RECOMMENDATION]" "Consider restarting terminal for fresh context"
    else
        log "${GREEN}[GOOD]" "Context within optimal range"
    fi
}

# Show context status
show_context_status() {
    log "${BLUE}[STATUS]" "Context Engineering Status"
    echo
    
    # Current usage
    local current_kb=$(ps -o rss= -p $$ | tr -d ' ' || echo "0")
    local context_ratio=$(( current_kb * 100 / CONTEXT_BUDGET_KB ))
    
    echo "Context Usage:"
    echo "  Current: ${current_kb}KB (${context_ratio}%)"
    echo "  Budget: ${CONTEXT_BUDGET_KB}KB"
    echo
    
    # Pattern availability
    local current_dir=$(basename "$PWD")
    local pattern_file="$CONTEXT_PATTERNS_DIR/${current_dir}_patterns.md"
    
    if [[ -f "$pattern_file" ]]; then
        echo "Project Patterns: Available"
        echo "  File: $pattern_file"
        pattern_count=$(grep -c "###" "$pattern_file" 2>/dev/null || echo "0")
        echo "  Learned patterns: $pattern_count"
    else
        echo "Project Patterns: None available"
    fi
    echo
    
    # Project memory
    local project_memory="./.context-memory.md"
    if [[ -f "$project_memory" ]]; then
        echo "Project Memory: Active"
        local last_update=$(grep "Last updated:" "$project_memory" | cut -d: -f2- | sed 's/^ *//' || echo "Unknown")
        echo "  Last updated: $last_update"
    else
        echo "Project Memory: Not initialized"
    fi
}

# Clean context systems
clean_context_systems() {
    log "${BLUE}[CLEANUP]" "Cleaning context engineering systems..."
    
    # Clean old cache files
    local cache_dir="$MEMORY_SYSTEMS_DIR/context-cache"
    find "$cache_dir" -name "*.tmp" -mtime +7 -delete 2>/dev/null || true
    
    # Clean old pattern files (optional based on age)
    find "$MEMORY_SYSTEMS_DIR/patterns" -name "*.md" -mtime +30 -delete 2>/dev/null || true
    
    # Optimize shell history
    optimize_context >/dev/null
    
    log "${GREEN}[SUCCESS]" "Context systems cleaned"
}

# Main execution based on command
case "${1:-init}" in
    "init")
        init_context_infrastructure
        create_project_memory
        configure_terminal_context
        create_context_monitor
        log "${GREEN}[COMPLETE]" "Context engineering initialized - restart terminal to activate"
        ;;
    "optimize")
        optimize_context
        ;;
    "status")
        show_context_status
        ;;
    "clean")
        clean_context_systems
        ;;
    "patterns")
        echo "To learn patterns: ctx-learn-success <task_type> <context_summary>"
        echo "To view patterns: ctx-patterns-view"
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 {init|optimize|status|clean|patterns|help}"
        echo "  init      - Initialize context engineering infrastructure"
        echo "  optimize  - Optimize current context usage"  
        echo "  status    - Show context status and statistics"
        echo "  clean     - Clean old context caches and patterns"
        echo "  patterns  - Show pattern learning commands"
        ;;
    *)
        log "${RED}[ERROR]" "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

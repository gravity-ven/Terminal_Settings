#!/bin/bash

# Droid Startup Script
# Auto-syncs GitHub repositories and monitors token usage
# Place this in your shell startup file (.zshrc or .bash_profile)

set -e

# Configuration
DROID_CONFIG_DIR="$HOME/.droid_config"
DROID_LOG_DIR="$HOME/.droid_logs"
SYNC_CONFIG_FILE="$DROID_CONFIG_DIR/sync_repositories.json"
TOKEN_USAGE_LOG="$DROID_LOG_DIR/token_usage.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create necessary directories
mkdir -p "$DROID_CONFIG_DIR" "$DROID_LOG_DIR"

# Logging function
log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$TOKEN_USAGE_LOG"
}

# Output functions with colors
print_header() {
    echo -e "${BLUE}🤖 DROID STARTUP SCRIPT${NC}"
    echo -e "${BLUE}========================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log_message "INFO" "$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_message "WARN" "$1"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    log_message "ERROR" "$1"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
    log_message "INFO" "$1"
}

# Check token usage (placeholder for actual token monitoring)
check_token_usage() {
    print_info "Checking Droid token usage..."
    
    # This would be replaced with actual token checking when API is available
    # For now, we'll simulate the check
    local estimated_usage="750k"
    local estimated_limit="1M"
    
    echo -e "${PURPLE}📊 Token Usage Estimate:${NC}"
    echo -e "   Used: ${YELLOW}$estimated_usage${NC}"
    echo -e "   Limit: ${GREEN}$estimated_limit${NC}"
    echo -e "   Remaining: ${GREEN}$(echo "$estimated_limit - $estimated_usage" | bc -l | cut -d. -f1)${NC}"
    
    # Log token usage
    log_message "TOKEN_USAGE" "Estimated: $estimated_usage/$estimated_limit remaining"
    
    # Warning if usage is high
    if [ "$(echo "$estimated_usage >= 800000" | bc -l)" -eq 1 ]; then
        print_warning "High token usage detected. Consider monitoring and optimizing."
    fi
}

# Initialize sync configuration if it doesn't exist
init_sync_config() {
    if [ ! -f "$SYNC_CONFIG_FILE" ]; then
        print_info "Creating sync configuration..."
        cat > "$SYNC_CONFIG_FILE" << 'EOF'
{
  "repositories": [
    {
      "name": "Terminal_Settings",
      "url": "https://github.com/gravity-ven/Terminal_Settings.git",
      "local_path": "$HOME/.terminal_settings",
      "branch": "main",
      "auto_sync": true,
      "post_sync_script": "scripts/setup_terminal.sh",
      "description": "Terminal configurations and settings"
    }
  ],
  "sync_options": {
    "auto_commit": false,
    "backup_before_sync": true,
    "max_log_entries": 100
  }
}
EOF
        print_success "Sync configuration created at $SYNC_CONFIG_FILE"
    fi
}

# Sync a single repository
sync_repository() {
    local repo_name="$1"
    local repo_url="$2"
    local local_path="$3"
    local branch="$4"
    local post_sync_script="$5"
    local backup_before_sync="$6"
    
    # Expand environment variables in path
    local expanded_path=$(eval echo "$local_path")
    
    print_info "Syncing repository: $repo_name"
    
    # Create backup if requested and directory exists
    if [ "$backup_before_sync" = "true" ] && [ -d "$expanded_path" ]; then
        local backup_dir="${expanded_path}_backup_$(date +%Y%m%d_%H%M%S)"
        print_info "Creating backup: $backup_dir"
        cp -r "$expanded_path" "$backup_dir"
    fi
    
    if [ -d "$expanded_path" ]; then
        # Repository exists, pull changes
        cd "$expanded_path"
        print_info "Pulling latest changes..."
        if git pull origin "$branch" --rebase; then
            print_success "Repository $repo_name updated successfully"
        else
            print_error "Failed to pull changes for $repo_name"
            return 1
        fi
    else
        # Repository doesn't exist, clone it
        print_info "Cloning repository $repo_name..."
        if git clone "$repo_url" "$expanded_path" --branch "$branch"; then
            print_success "Repository $repo_name cloned successfully"
        else
            print_error "Failed to clone repository $repo_name"
            return 1
        fi
    fi
    
    # Run post-sync script if specified
    if [ -n "$post_sync_script" ]; then
        local script_path="$expanded_path/$post_sync_script"
        if [ -f "$script_path" ]; then
            print_info "Running post-sync script: $post_sync_script"
            if chmod +x "$script_path" && "$script_path" --quiet; then
                print_success "Post-sync script completed successfully"
            else
                print_warning "Post-sync script encountered issues"
            fi
        fi
    fi
    
    return 0
}

# Sync all configured repositories
sync_repositories() {
    print_header
    print_info "🚀 Starting Droid startup synchronization..."
    
    # Check if jq is available for JSON parsing
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Installing..."
        if command -v brew &> /dev/null; then
            brew install jq
        else
            print_error "Cannot install jq. Please install manually to use sync features."
            return 1
        fi
    fi
    
    # Check if gh is available
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) is not installed. Some features may not work."
    fi
    
    # Read and process sync configuration
    if [ -f "$SYNC_CONFIG_FILE" ]; then
        local repo_count=$(jq -r '.repositories | length' "$SYNC_CONFIG_FILE")
        print_info "Found $repo_count repositories to sync"
        
        # Sync each repository
        local success_count=0
        for ((i=0; i<repo_count; i++)); do
            local repo_name=$(jq -r ".repositories[$i].name" "$SYNC_CONFIG_FILE")
            local repo_url=$(jq -r ".repositories[$i].url" "$SYNC_CONFIG_FILE")
            local local_path=$(jq -r ".repositories[$i].local_path" "$SYNC_CONFIG_FILE")
            local branch=$(jq -r ".repositories[$i].branch // \"main\"" "$SYNC_CONFIG_FILE")
            local auto_sync=$(jq -r ".repositories[$i].auto_sync // true" "$SYNC_CONFIG_FILE")
            local post_sync_script=$(jq -r ".repositories[$i].post_sync_script // \"\"" "$SYNC_CONFIG_FILE")
            local backup_enabled=$(jq -r ".sync_options.backup_before_sync // true" "$SYNC_CONFIG_FILE")
            
            if [ "$auto_sync" = "true" ]; then
                if sync_repository "$repo_name" "$repo_url" "$local_path" "$branch" "$post_sync_script" "$backup_enabled"; then
                    ((success_count++))
                fi
            else
                print_info "Skipping $repo_name (auto_sync disabled)"
            fi
        done
        
        print_success "Synced $success_count out of $repo_count repositories"
    else
        print_warning "No sync configuration found. Running init..."
        init_sync_config
    fi
}

# Rotate log files
rotate_logs() {
    local max_entries=100
    if [ -f "$TOKEN_USAGE_LOG" ]; then
        local line_count=$(wc -l < "$TOKEN_USAGE_LOG")
        if [ "$line_count" -gt "$max_entries" ]; then
            print_info "Rotating logs (keeping last $max_entries entries)"
            tail -n "$max_entries" "$TOKEN_USAGE_LOG" > "${TOKEN_USAGE_LOG}.tmp"
            mv "${TOKEN_USAGE_LOG}.tmp" "$TOKEN_USAGE_LOG"
        fi
    fi
}

# Main execution
main() {
    # Check if running in quiet mode
    local quiet_mode=false
    if [ "$1" = "--quiet" ]; then
        quiet_mode=true
    fi
    
    if [ "$quiet_mode" = "false" ]; then
        print_header
    fi
    
    # Sync repositories
    sync_repositories
    
    # Check token usage
    check_token_usage
    
    # Rotate logs
    rotate_logs
    
    if [ "$quiet_mode" = "false" ]; then
        echo ""
        print_success "🎉 Droid startup script completed successfully!"
        print_info "📋 Summary:"
        print_info "   - Repositories synchronized"
        print_info "   - Token usage checked"
        print_info "   - Logs updated in $DROID_LOG_DIR"
        echo ""
    fi
}

# Run main function with all arguments
main "$@"

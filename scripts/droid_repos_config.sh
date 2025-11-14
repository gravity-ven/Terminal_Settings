#!/bin/bash

# Droid Repository Configuration Manager
# Add, remove, and manage GitHub repositories for auto-sync

set -e

# Configuration
DROID_CONFIG_DIR="$HOME/.droid_config"
SYNC_CONFIG_FILE="$DROID_CONFIG_DIR/sync_repositories.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output functions
print_header() {
    echo -e "${BLUE}🤖 DROID REPOSITORY CONFIGURATION MANAGER${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Ensure jq is available
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. Installing..."
        if command -v brew &> /dev/null; then
            brew install jq
        else
            print_error "Cannot install jq. Please install manually."
            exit 1
        fi
    fi
}

# Initialize config file if it doesn't exist
init_config() {
    mkdir -p "$DROID_CONFIG_DIR"
    if [ ! -f "$SYNC_CONFIG_FILE" ]; then
        cat > "$SYNC_CONFIG_FILE" << 'EOF'
{
  "repositories": [],
  "sync_options": {
    "auto_commit": false,
    "backup_before_sync": true,
    "max_log_entries": 100
  }
}
EOF
        print_success "Configuration file initialized"
    fi
}

# Add a new repository
add_repository() {
    local name="$1"
    local url="$2"
    local local_path="$3"
    local branch="${4:-main}"
    local post_sync_script="${5:-}"
    local description="${6:-Repository synchronized via Droid}"
    
    print_info "Adding repository: $name"
    
    # Check if repository already exists
    local repo_count=$(jq -r ".repositories | map(select(.name == \"$name\")) | length" "$SYNC_CONFIG_FILE")
    if [ "$repo_count" -gt 0 ]; then
        print_error "Repository '$name' already exists"
        return 1
    fi
    
    # Add new repository to config
    local temp_file=$(mktemp)
    jq --arg name "$name" \
       --arg url "$url" \
       --arg local_path "$local_path" \
       --arg branch "$branch" \
       --arg post_sync_script "$post_sync_script" \
       --arg description "$description" \
       '.repositories += [{
         "name": $name,
         "url": $url,
         "local_path": $local_path,
         "branch": $branch,
         "auto_sync": true,
         "post_sync_script": $post_sync_script,
         "description": $description
       }]' "$SYNC_CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$SYNC_CONFIG_FILE"
    
    print_success "Repository '$name' added successfully"
}

# Remove a repository
remove_repository() {
    local name="$1"
    
    print_info "Removing repository: $name"
    
    # Remove repository from config
    local temp_file=$(mktemp)
    jq --arg name "$name" '.repositories |= map(select(.name != $name))' "$SYNC_CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$SYNC_CONFIG_FILE"
    
    print_success "Repository '$name' removed successfully"
}

# List all repositories
list_repositories() {
    print_info "Configured repositories:"
    echo ""
    
    local repo_count=$(jq -r '.repositories | length' "$SYNC_CONFIG_FILE")
    if [ "$repo_count" -eq 0 ]; then
        print_warning "No repositories configured"
        return
    fi
    
    printf "${PURPLE}%-20s %-30s %-30s %-10s %s${NC}\n" "NAME" "URL" "LOCAL PATH" "BRANCH" "AUTO_SYNC"
    echo "----------------------------------------"
    
    for ((i=0; i<repo_count; i++)); do
        local name=$(jq -r ".repositories[$i].name" "$SYNC_CONFIG_FILE")
        local url=$(jq -r ".repositories[$i].url" "$SYNC_CONFIG_FILE")
        local local_path=$(jq -r ".repositories[$i].local_path" "$SYNC_CONFIG_FILE")
        local branch=$(jq -r ".repositories[$i].branch" "$SYNC_CONFIG_FILE")
        local auto_sync=$(jq -r ".repositories[$i].auto_sync" "$SYNC_CONFIG_FILE")
        local description=$(jq -r ".repositories[$i].description" "$SYNC_CONFIG_FILE")
        
        printf "%-20s %-30s %-30s %-10s %s\n" "$name" "$url" "$local_path" "$branch" "$auto_sync"
        if [ "$description" != "null" ] && [ -n "$description" ]; then
            printf "${CYAN}    %s${NC}\n" "$description"
        fi
        echo ""
    done
}

# Toggle auto-sync for a repository
toggle_sync() {
    local name="$1"
    
    print_info "Toggling auto-sync for: $name"
    
    # Check if repository exists
    local repo_count=$(jq -r ".repositories | map(select(.name == \"$name\")) | length" "$SYNC_CONFIG_FILE")
    if [ "$repo_count" -eq 0 ]; then
        print_error "Repository '$name' not found"
        return 1
    fi
    
    # Toggle auto_sync
    local temp_file=$(mktemp)
    jq --arg name "$name" \
       '.repositories |= map(if .name == $name then .auto_sync = (.auto_sync | not) else . end)' \
       "$SYNC_CONFIG_FILE" > "$temp_file" && mv "$temp_file" "$SYNC_CONFIG_FILE"
    
    local new_status=$(jq -r ".repositories[] | select(.name == \"$name\") | .auto_sync" "$SYNC_CONFIG_FILE")
    print_success "Repository '$name' auto-sync set to: $new_status"
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  add <name> <url> <local_path> [branch] [post_sync_script] [description]"
    echo "    Add a new repository to sync configuration"
    echo ""
    echo "  remove <name>"
    echo "    Remove a repository from sync configuration"
    echo ""
    echo "  list"
    echo "    List all configured repositories"
    echo ""
    echo "  toggle <name>"
    echo "    Toggle auto-sync for a repository"
    echo ""
    echo "  help"
    echo "    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 add 'my-configs' 'https://github.com/user/configs.git' '$HOME/.configs'"
    echo "  $0 add 'dotfiles' 'https://github.com/user/dotfiles.git' '\$HOME/.dotfiles' 'main' 'setup.sh'"
    echo "  $0 remove 'my-configs'"
    echo "  $0 list"
    echo "  $0 toggle 'my-configs'"
}

# Main execution
main() {
    print_header
    
    check_dependencies
    init_config
    
    case "${1:-help}" in
        "add")
            if [ $# -lt 4 ]; then
                print_error "Insufficient arguments for 'add' command"
                show_help
                exit 1
            fi
            add_repository "$2" "$3" "$4" "${5:-main}" "${6:-}" "${7:-}"
            ;;
        "remove")
            if [ $# -lt 2 ]; then
                print_error "Repository name required for 'remove' command"
                show_help
                exit 1
            fi
            remove_repository "$2"
            ;;
        "list")
            list_repositories
            ;;
        "toggle")
            if [ $# -lt 2 ]; then
                print_error "Repository name required for 'toggle' command"
                show_help
                exit 1
            fi
            toggle_sync "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"

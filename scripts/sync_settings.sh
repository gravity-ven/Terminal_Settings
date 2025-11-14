#!/bin/bash

# Terminal Settings Synchronization Script
# Enhanced with automatic memory optimization syncing
# This script pushes local changes to GitHub and pulls updates from remote

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMINAL_SETTINGS_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    local level=$1
    shift
    echo -e "${level} $*"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMINAL_SETTINGS_DIR="$(dirname "$SCRIPT_DIR")"

cd "$TERMINAL_SETTINGS_DIR"

log "${BLUE}[SYNC]" "Synchronizing terminal settings with memory optimizations..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    log "${RED}[ERROR]" "Not a git repository. Please initialize the git repository first."
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    log "${YELLOW}[COMMIT]" "Committing local changes including memory optimizations..."
    
    # Add all changes
    git add .
    
    # Get a timestamp and analyze changes for commit message
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check if memory optimization files were changed
    memory_changes=$(git diff --cached --name-only | grep -E "(memory|zshrc|bash_profile|tmux\.conf|alacritty|ghostty|wezterm)" || true)
    
    if [ -n "$memory_changes" ]; then
        commit_msg="Optimize terminal memory usage - $timestamp

- Enhanced shell configurations for memory efficiency
- Optimized terminal emulator settings (Alacritty, Ghostty, WezTerm)
- Improved tmux memory management
- Added memory monitoring and cleanup utilities

Co-authored-by: factory-droid[bot] <138933559+factory-droid[bot]@users.noreply.github.com>"
    else
        commit_msg="Update terminal settings - $timestamp

Co-authored-by: factory-droid[bot] <138933559+factory-droid[bot]@users.noreply.github.com>"
    fi
    
    git commit -m "$commit_msg"
    
    log "${GREEN}[SUCCESS]" "Changes committed locally with memory optimizations"
else
    log "${BLUE}[INFO]" "No local changes to commit"
fi

# Pull latest changes from remote
log "${BLUE}[PULL]" "Pulling latest changes from remote..."
if git pull origin main --rebase; then
    log "${GREEN}[SUCCESS]" "Remote changes pulled successfully"
else
    log "${YELLOW}[WARNING]" "Pull had conflicts or remote not available"
fi

# Push changes to remote
log "${BLUE}[PUSH]" "Pushing changes to remote..."
if git push origin main; then
    log "${GREEN}[SUCCESS]" "Changes pushed to remote repository"
else
    log "${RED}[ERROR]" "Failed to push to remote. Check your network/permissions."
    exit 1
fi

log "${GREEN}[COMPLETE]" "Terminal settings synchronized with memory optimizations!"

# Optional: Run setup after sync
read -p "Do you want to apply the updated settings to your current environment? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔧 Applying updated settings..."
    "$SCRIPT_DIR/setup_terminal.sh"
fi

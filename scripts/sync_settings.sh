#!/bin/bash

# Terminal Settings Synchronization Script
# This script pushes local changes to GitHub and pulls updates from remote

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMINAL_SETTINGS_DIR="$(dirname "$SCRIPT_DIR")"

cd "$TERMINAL_SETTINGS_DIR"

echo "🔄 Synchronizing terminal settings..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository. Please initialize the git repository first."
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 Committing local changes..."
    
    # Add all changes
    git add .
    
    # Get a timestamp for the commit message
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Commit with informative message
    git commit -m "Update terminal settings - $timestamp

Co-authored-by: factory-droid[bot] <138933559+factory-droid[bot]@users.noreply.github.com>"
    
    echo "✅ Changes committed locally"
fi

# Pull latest changes from remote
echo "📥 Pulling latest changes from remote..."
git pull origin main --rebase

# Push changes to remote
echo "📤 Pushing changes to remote..."
git push origin main

echo "🎉 Terminal settings synchronized successfully!"

# Optional: Run setup after sync
read -p "Do you want to apply the updated settings to your current environment? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔧 Applying updated settings..."
    "$SCRIPT_DIR/setup_terminal.sh"
fi

#!/bin/bash

# Terminal Settings Dependencies Installer
# This script installs all required dependencies for the terminal configurations

set -e

echo "🚀 Installing terminal dependencies..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew already installed"
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Install core dependencies
echo "📦 Installing core dependencies..."
brew install starship
brew install gh
brew install tmux

# Install terminal emulators (optional)
read -p "Do you want to install terminal emulators (WezTerm, Alacritty, Ghostty)? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Installing WezTerm..."
    brew install --cask wezterm
    
    echo "📦 Installing Alacritty..."
    brew install --cask alacritty
    
    echo "📦 Installing Ghostty..."
    brew install --cask ghostty
fi

# Check for Ghostty (may not be available via brew yet)
if ! command -v ghostty &> /dev/null; then
    echo "⚠️  Ghostty may need manual installation from: https://ghostty.org"
fi

# Install tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "📦 Installing TMUX Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "✅ TMUX Plugin Manager already installed"
fi

echo "✅ All dependencies installed successfully!"
echo "🎯 Run './scripts/setup_terminal.sh' to configure your terminal environment."

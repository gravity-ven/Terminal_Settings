#!/bin/bash

# Terminal Environment Setup Script
# This script configures your terminal environment with all settings

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERMINAL_SETTINGS_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔧 Setting up terminal environment..."
echo "📂 Using terminal settings from: $TERMINAL_SETTINGS_DIR"

# Backup existing configurations
echo "💾 Creating backups of existing configurations..."
backup_dir="$HOME/.terminal_settings_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$backup_dir/.zshrc"
[ -f "$HOME/.zprofile" ] && cp "$HOME/.zprofile" "$backup_dir/.zprofile"
[ -f "$HOME/.bash_profile" ] && cp "$HOME/.bash_profile" "$backup_dir/.bash_profile"
[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$backup_dir/.tmux.conf"
[ -d "$HOME/.config/ghostty" ] && cp -r "$HOME/.config/ghostty" "$backup_dir/"
[ -d "$HOME/.config/alacritty" ] && cp -r "$HOME/.config/alacritty" "$backup_dir/"
[ -d "$HOME/.config/wezterm" ] && cp -r "$HOME/.config/wezterm" "$backup_dir/"

echo "✅ Backups created in: $backup_dir"

# Create necessary directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"

# Setup ZSH configuration
echo "⚙️  Setting up ZSH configuration..."
cp "$TERMINAL_SETTINGS_DIR/zsh/.zshrc" "$HOME/.zshrc"
cp "$TERMINAL_SETTINGS_DIR/zsh/.zprofile" "$HOME/.zprofile"

# Setup Bash configuration
echo "⚙️  Setting up Bash configuration..."
cp "$TERMINAL_SETTINGS_DIR/bash/.bash_profile" "$HOME/.bash_profile"

# Setup Tmux configuration
echo "⚙️  Setting up Tmux configuration..."
cp "$TERMINAL_SETTINGS_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Setup terminal emulator configurations
echo "⚙️  Setting up terminal emulator configurations..."

# Ghostty
if [ -d "$TERMINAL_SETTINGS_DIR/ghostty" ]; then
    mkdir -p "$HOME/.config/ghostty"
    cp -r "$TERMINAL_SETTINGS_DIR/ghostty/"* "$HOME/.config/ghostty/"
    echo "✅ Ghostty configuration set up"
fi

# Alacritty
if [ -d "$TERMINAL_SETTINGS_DIR/alacritty" ]; then
    mkdir -p "$HOME/.config/alacritty"
    cp -r "$TERMINAL_SETTINGS_DIR/alacritty/"* "$HOME/.config/alacritty/"
    echo "✅ Alacritty configuration set up"
fi

# WezTerm
if [ -d "$TERMINAL_SETTINGS_DIR/wezterm" ]; then
    mkdir -p "$HOME/.config/wezterm"
    cp -r "$TERMINAL_SETTINGS_DIR/wezterm/"* "$HOME/.config/wezterm/"
    echo "✅ WezTerm configuration set up"
fi

# Setup Starship prompt
echo "⚙️  Setting up Starship prompt..."
if [ -f "$TERMINAL_SETTINGS_DIR/prompt/starship.toml" ]; then
    mkdir -p "$HOME/.config"
    cp "$TERMINAL_SETTINGS_DIR/prompt/starship.toml" "$HOME/.config/starship.toml"
    echo "✅ Starship configuration set up"
fi

# Install TMUX plugins
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "📦 Installing TMUX plugins..."
    $HOME/.tmux/plugins/tpm/bin/install_plugins
fi

# Set proper permissions
chmod +x "$HOME/.tmux/plugins/tpm/bin/install_plugins"

echo "🎉 Terminal environment setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. If using TMUX, press prefix + I to install plugins"
echo "3. Enjoy your configured terminal environment!"
echo ""
echo "💾 Your original configurations are backed up in: $backup_dir"

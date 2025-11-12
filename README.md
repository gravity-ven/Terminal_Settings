# Terminal Settings

A comprehensive collection of terminal configurations and settings for various terminal emulators and shells, designed for seamless synchronization across multiple environments.

## 📁 Structure

```
Terminal_Settings/
├── zsh/              # Zsh shell configuration
│   ├── .zshrc
│   └── .zprofile
├── bash/             # Bash shell configuration
│   └── .bash_profile
├── tmux/             # TMUX terminal multiplexer configuration
│   └── .tmux.conf
├── ghostty/          # Ghostty terminal emulator settings
│   └── config
├── alacritty/        # Alacritty terminal emulator settings
│   ├── alacritty.toml
│   ├── alacritty.yml
│   ├── solarized-osaka.toml
│   └── solarized-osaka.yml
├── wezterm/          # WezTerm terminal emulator settings
│   └── wezterm.lua
├── prompt/           # Prompt configuration (Starship)
│   └── starship.toml
└── scripts/          # Installation and management scripts
    ├── install_dependencies.sh
    ├── setup_terminal.sh
    └── sync_settings.sh
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/Terminal_Settings.git ~/.terminal_settings
cd ~/.terminal_settings
```

### 2. Install Dependencies

```bash
chmod +x scripts/install_dependencies.sh
./scripts/install_dependencies.sh
```

### 3. Setup Your Terminal Environment

```bash
chmod +x scripts/setup_terminal.sh
./scripts/setup_terminal.sh
```

### 4. Restart Your Terminal

After setup, restart your terminal or run:
```bash
source ~/.zshrc
```

## 📋 Features

- **Multi-terminal Support**: Configurations for Zsh, Bash, TMUX, Ghostty, Alacritty, and WezTerm
- **Auto-sync**: Synchronize settings across all your environments
- **Backup Protection**: Automatic backups of existing configurations
- **Dependency Management**: Automatic installation of required tools
- **Solarized Osaka Theme**: Consistent theme across all terminal emulators

## 🛠️ Available Scripts

### `install_dependencies.sh`
Installs all required dependencies:
- Homebrew (if not installed)
- Starship prompt
- GitHub CLI
- TMUX
- Terminal emulators (optional)
- TMUX Plugin Manager

### `setup_terminal.sh`
Configures your terminal environment:
- Creates backups of existing configurations
- Sets up shell configurations (Zsh/Bash)
- Configures terminal emulators
- Installs TMUX plugins
- Sets up Starship prompt

### `sync_settings.sh`
Synchronizes settings between local and GitHub:
- Commits local changes
- Pulls remote updates
- Pushes to remote repository
- Optional: Apply updates to current environment

## 🔧 Manual Configuration

### Zsh Configuration
The `.zshrc` file includes:
- Path configurations for local binaries
- Starship prompt initialization
- Conda environment support

### TMUX Configuration
Features:
- Solarized Osaka theme
- Tab-like status bar
- Mouse support
- Vi key bindings
- Optimized for AI workloads

### Terminal Emulators
Each terminal emulator is configured with:
- Solarized Osaka color scheme
- Consistent font settings
- Optimized key bindings

## 🔄 Setting Up Auto-sync

To automatically sync your settings across environments, create a cron job or add to your shell's startup:

```bash
# Add to your .zshrc or .bash_profile
# Auto sync terminal settings monthly
if [ -d "$HOME/.terminal_settings" ]; then
    "$HOME/.terminal_settings/scripts/sync_settings.sh" --quiet
fi
```

## 🎨 Customization

### Adding Your Own Configurations
1. Add your configuration files to the appropriate directory
2. Commit and push changes:
   ```bash
   git add .
   git commit -m "Add custom configuration"
   git push origin main
   ```

### Modifying Themes
Edit the theme files in each terminal emulator's directory:
- `solarized-osaka.yml` for Alacritty
- `solarized-osaka.toml` for Alacritty (TOML format)
- Terminal-specific config files for others

## 🚨 Troubleshooting

### Backup Restoration
If you need to restore your original configurations:
```bash
# Find your backup directory
ls ~/.terminal_settings_backup_*

# Restore specific files
cp ~/.terminal_settings_backup_YYYYMMDD_HHMMSS/.zshrc ~/.zshrc
```

### Plugin Issues
If TMUX plugins don't install:
```bash
# In TMUX, press prefix + I to install plugins
# Or manually install:
~/.tmux/plugins/tpm/bin/install_plugins
```

### Permission Issues
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

## 📚 Dependencies

### Required
- **Zsh** or **Bash**: Shell
- **Starship**: Customizable prompt
- **TMUX**: Terminal multiplexer
- **Git**: Version control

### Optional (Terminal Emulators)
- **Ghostty**: Modern terminal emulator
- **Alacritty**: GPU-accelerated terminal
- **WezTerm**: Cross-platform terminal

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on a clean environment
5. Submit a pull request

## 📄 License

This repository is licensed under the MIT License.

## 🔗Links

- [Starship Prompt](https://starship.rs/)
- [TMUX](https://github.com/tmux/tmux)
- [Alacritty](https://alacritty.org/)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [Ghostty](https://ghostty.org/)
- [Solarized Osaka](https://github.com/hachy/solarized-osaka)

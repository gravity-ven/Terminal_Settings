# Memory-efficient PATH configuration
typeset -U path  # Remove duplicates
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/Users/spartan/.pixi/bin:$PATH"

# Starship prompt (memory-optimized)
eval "$(starship init zsh)"

# Memory optimization settings
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY
setopt SHARED_HISTORY APPEND_HISTORY

# Disable unused features for memory efficiency
unsetopt AUTO_CD
unsetopt BEEP

# Limit command completion cache
zstyle ':completion:*' cache-path ~/.cache/zsh/completion-cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-size 1000

# Memory monitoring function
mem_alert() {
  local mem_usage=$(ps -o rss= -p $$ | tr -d ' ')
  if [[ $mem_usage -gt 50000 ]]; then
    echo "⚠️  Shell memory usage high: ${mem_usage}KB"
  fi
}

# Auto-cleanup memory on large commands
preexec() {
  mem_alert
}

# Clean up history periodically
autoload -U add-zsh-hook
add-zsh-hook -z exit cleanup_history
cleanup_history() {
  fc -W
  fc -R
}

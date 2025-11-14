
# Memory-efficient bash configuration
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"

# Memory optimization settings
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=ignoredups:ignorespace

# Limit command completion
complete -r 2>/dev/null || true

# Memory monitoring function
mem_alert() {
  local mem_usage=$(ps -o rss= -p $$ | tr -d ' ')
  if [[ $mem_usage -gt 50000 ]]; then
    echo "⚠️  Shell memory usage high: ${mem_usage}KB"
  fi
}

# Auto-cleanup before commands
preexec() {
  mem_alert
}

trap 'preexec' DEBUG

# Clean up history on exit
cleanup_history() {
  history -w
  history -c
  history -r
}
trap cleanup_history EXIT

# >>> conda initialize (memory-optimized) >>>
# !! Contents within this block are managed by 'conda init' !!
# Only initialize if conda is actually used
if command -v conda >/dev/null 2>&1 && [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi
# <<< conda initialize <<<


-- WezTerm configuration for AI workloads with Solarized Osaka theme
-- Optimized for memory efficiency and productivity

local wezterm = require 'wezterm'
local config = {}

-- Solarized Osaka color scheme
local solarized_osaka = {
  foreground = "#93a1a1",
  background = "#002b36",
  cursor_bg = "#93a1a1",
  cursor_fg = "#002b36",
  cursor_border = "#93a1a1",
  selection_bg = "#073642",
  selection_fg = "#93a1a1",
  
  ansi = {
    "#073642", -- black (base01)
    "#dc322f", -- red
    "#859900", -- green
    "#b58900", -- yellow
    "#268bd2", -- blue
    "#d33682", -- magenta
    "#2aa198", -- cyan
    "#eee8d5", -- white (base2)
  },
  
  brights = {
    "#002b36", -- bright black (base03)
    "#cb4b16", -- bright red (orange)
    "#586e75", -- bright green (base01)
    "#657b83", -- bright yellow (base00)
    "#839496", -- bright blue (base0)
    "#6c71c4", -- bright magenta (violet)
    "#073642", -- bright cyan (base02)
    "#fdf6e3", -- bright white (base3)
  },
}

config.color_schemes = {
  ['Solarized Osaka'] = solarized_osaka,
}
config.color_scheme = 'Solarized Osaka'

-- Font configuration
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 20

-- Tab bar configuration
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.tab_max_width = 100

-- Window settings for AI workloads
config.window_background_opacity = 0.95
config.enable_scroll_bar = false
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Performance optimizations (memory efficient)
config.max_fps = 30
config.scrollback_lines = 5000  -- Reduced from 10000

-- Memory efficiency optimizations
-- Reduce unnecessary features
config.enable_wayland = false
config.front_end = "WebGpu"  -- More memory efficient than OpenGL
config.window_close_confirmation = "NeverPrompt"

-- Optimize rendering
config.enable_kitty_keyboard = true
config.enable_csi_u_key_encoding = true

-- Reduce memory usage for tab bar
config.show_tab_index_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- Key bindings for productivity
config.keys = {
  -- Tab management
  { key = 't', mods = 'CTRL', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
  { key = 'w', mods = 'CTRL', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  
  -- Split management
  { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = '-', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
}

-- Mouse bindings
config.mouse_bindings = {
  -- Ctrl-click to open link
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- AI workload optimizations
config.adjust_window_size_when_changing_font_size = false
config.automatically_reload_config = true
config.check_for_updates = false

-- Multiplexing
config.unix_domains = {
  {
    name = 'unix-domain',
  },
}

-- Default shell
config.default_prog = { '/bin/zsh', '-l' }

return config

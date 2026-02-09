-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.check_for_updates = false

config.enable_tab_bar = false

config.color_scheme = 'GitHub Dark'
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium', italic = false })
config.font_size = 14
config.default_prog = { '@zellij_path@' }
config.skip_close_confirmation_for_processes_named = {'wsl', 'cmd', 'powershell', 'zellij', 'fish', 'tmux'}

-- fix for some issue on latest nix package update
-- https://github.com/wez/wezterm/issues/5990
config.front_end = 'WebGpu'

-- and finally, return the configuration to wezterm
return config

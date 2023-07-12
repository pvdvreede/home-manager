local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- config.default_prog = { '/usr/bin/env', 'tmux' }
config.enable_tab_bar = false

config.font_size = 14.0

return config

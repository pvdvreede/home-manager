-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.check_for_updates = false

config.enable_tab_bar = false

config.color_scheme = 'Adventure'
config.font_size = 16
config.default_prog = { '@zellij_path@' }

-- and finally, return the configuration to wezterm
return config

{...}: {
  home.file.weztermConfig = {
    executable = false;
    target = "/.config/wezterm.lua";
    text = ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'

      -- This will hold the configuration.
      local config = wezterm.config_builder()

      -- This is where you actually apply your config choices
      config.enable_tab_bar = false

      -- For example, changing the color scheme:
      config.color_scheme = 'AdventureTime'

      -- and finally, return the configuration to wezterm
      return config
    '';
  };

  # we need to copy this to the windows side outside of the home dir
  home.activation.copyWeztermConfig = {
    after = ["writeBoundary"];
    before = [];
    data = ''
      cp $HOME/.config/wezterm.lua /mnt/c/Users/pvdvreede/.wezterm.lua
    '';
  };
}

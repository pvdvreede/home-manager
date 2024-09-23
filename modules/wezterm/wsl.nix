{pkgs, ...}: {
  home.file.weztermConfig = {
    source = pkgs.substituteAll {
      src = ./wezterm.lua;
      zellij_path = "";
    };
    executable = false;
    target = "/.config/wezterm.lua";
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

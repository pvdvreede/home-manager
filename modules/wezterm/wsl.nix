{pkgs, ...}: {
  home.file.weztermConfig = {
    source = pkgs.substituteAll {
      src = ./wezterm.lua;
      # need to do some lua table injection.
      zellij_path = "wsl', '--cd', '~', '--', 'bash', '-c', '${pkgs.tmux}/bin/tmux new-session -A -s scratch";
    };
    executable = false;
    target = "/.config/wezterm.lua";
  };

  # we need to copy this to the windows side outside of the home dir
  home.activation.copyWeztermConfig = {
    after = ["writeBoundary"];
    before = [];
    data = ''
      mkdir -p /mnt/c/Users/pvdvreede
      cp -L .config/wezterm.lua /mnt/c/Users/pvdvreede/.wezterm.lua
      chmod 0664  /mnt/c/Users/pvdvreede/.wezterm.lua
    '';
  };
}

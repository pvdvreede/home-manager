{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "${pkgs.elvish}/bin/elvish";
      default_layout = "compact";
      pane_frames = false;
      theme = "nord";
      keybinds = {
        "normal clear-defaults=true"= {
          "bind \"Ctrl Space\"" = {
            SwitchToMode = "tmux";
          };
          "bind \"F12\"" = {
            SwitchToMode = "locked";
          };
        };
        locked = {
          "bind \"F12\"" = {
            SwitchToMode = "normal";
          };
        };
        tmux = {
          "bind \"o\"" = {
            "LaunchOrFocusPlugin \"zellij:session-manager\"" = {
              floating = true;
            };
            SwitchToMode = "normal";
          };
          "bind \"v\"" = {
            NewPane = "Right";
            SwitchToMode = "normal";
          };
          "bind \"s\"" = {
            NewPane = "Down";
            SwitchToMode = "normal";
          };
        } //
          (builtins.foldl' (acc: i: {
            "bind \"${builtins.toString i}\"" = {
              GoToTab = i;
              SwitchToMode = "normal";
            };
          } // acc) {} [ 1 2 3 4 5 6 ]);
      };
    };
  };
}

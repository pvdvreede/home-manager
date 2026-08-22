{...}: {
  flake.homeModules.aerospace = {pkgs, ...}: {
    programs.aerospace = {
      enable = true;
      package = pkgs.emptyDirectory;
      launchd.enable = true;

      settings = {
        config-version = 2;
        # Initial gap configurations
        default-root-container-layout = "tiles";
        automatically-unhide-macos-hidden-apps = true;
        after-startup-command = [
          "exec-and-forget borders width=8 active_color=0xffe1e3e4 inactive_color=0xff494d64"
        ];
        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          alt-enter = "exec-and-forget kitty";

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          # See: https://nikitabobko.github.io/AeroSpace/commands#move
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          # See: https://nikitabobko.github.io/AeroSpace/commands#resize
          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";

          # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";

          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
        };
        gaps = {
          inner.horizontal = 10;
          inner.vertical = 10;
          outer.left = 10;
          outer.bottom = 10;
          outer.top = 10;
          outer.right = 10;
        };
      };
    };
  };
}

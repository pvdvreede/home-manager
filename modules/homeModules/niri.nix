{...}: {
  flake.homeModules.niri = {pkgs, ...}: {
    wayland.windowManager.niri = {
      enable = true;
      package = pkgs.niri;
      checkConfig = true;

      settings = {
        prefer-no-csd = {};

        layout = {
          gaps = 12;
          struts = {
            left = 10;
            right = 10;
            top = 10;
            bottom = 10;
          };
          focus-ring.width = 2;
        };

        input.touchpad = {
          tap = {};
        };

        _children = [
          {
            "layer-rule" = {
              "match"._props = {
                namespace = "^noctalia-bar-";
              };
              "background-effect" = {
                blur = false;
              };
            };
          }
        ];

        input = {
          focus-follows-mouse = {
            _props.max-scroll-amount = "0%";
          };
          warp-mouse-to-focus = {};
        };

        gestures.hot-corners.top-left = {};

        binds = {
          "Alt+Return" = {
            _props.hotkey-overlay-title = "Terminal";
            spawn = ["kitty" "-e" "fish"];
          };

          "Alt+Shift+O".open-overview = {};

          "Mod+Shift+E" = {
            quit = {};
          };

          "Alt+S" = {
            consume-window-into-column = {};
          };

          "Alt+Shift+S" = {
            expel-window-from-column = {};
          };

          "Mod+Space" = {
            spawn = ["noctalia" "msg" "panel-open" "launcher"];
          };

          "Mod+Shift+4" = {
            spawn = ["noctalia" "msg" "screenshot-region"];
          };

          "Mod+Q" = {close-window = {};};
          "Alt+F" = {maximize-column = {};};
          "Alt+Shift+F" = {fullscreen-window = {};};
          "Alt+Shift+Space" = {toggle-window-floating = {};};

          "Alt+H".focus-column-left = {};
          "Alt+L".focus-column-right = {};
          "Alt+K".focus-window-or-workspace-up = {};
          "Alt+J".focus-window-or-workspace-down = {};

          "Alt+1".focus-workspace = 1;
          "Alt+2".focus-workspace = 2;
          "Alt+3".focus-workspace = 3;

          "Alt+Shift+1".move-window-to-workspace = 1;
          "Alt+Shift+2".move-window-to-workspace = 2;
          "Alt+Shift+3".move-window-to-workspace = 3;
        };
      };
    };
  };
}

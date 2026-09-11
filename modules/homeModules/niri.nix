{...}:
{
  flake.homeModules.niri = {pkgs, ...}: {
    wayland.windowManager.niri = {
      enable = true;
      package = pkgs.niri;
      checkConfig = true;

      settings = {
        prefer-no-csd = {};

        layout = {
          gaps = 8;
          focus-ring.width = 2;
        };

        input.touchpad = {
          tap = {};
        };

        input = {
          focus-follows-mouse = {
            _props.max-scroll-amount = "0%";
          };
          warp-mouse-to-focus = {};
        };

        gestures.hot-corners.top-left = {};

        binds = {
          "Mod+Return" = {
            _props.hotkey-overlay-title = "Terminal";
            spawn = ["kitty" "-e" "fish"];
          };
          "Print" = {
            _props.hotkey-overlay-title = "Screenshot";
            spawn = ["grim"];
          };
          "Mod+Shift+Print" = {
            _props.hotkey-overlay-title = "Screenshot region";
            spawn = ["sh" "-c" "grim -g \"$(slurp)\""];
          };

          "Mod+Shift+O".open-overview = {};

          "Mod+Shift+E" = {
            quit = {};
          };

          "Mod+Space" = {
            spawn = ["noctalia" "msg" "panel-open" "launcher"];
          };

          "Mod+4" = {
            spawn = ["noctalia" "msg" "screenshot-region"];
          };

          "Mod+Q" = {close-window = {};};
          "Mod+F" = {maximize-column = {};};
          "Mod+Shift+F" = {fullscreen-window = {};};
          "Mod+Shift+Space" = {toggle-window-floating = {};};

          "Mod+H".focus-column-left = {};
          "Mod+L".focus-column-right = {};
          "Mod+K".focus-workspace-up = {};
          "Mod+J".focus-workspace-down = {};

          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;

          "Mod+Shift+1".move-window-to-workspace = 1;
          "Mod+Shift+2".move-window-to-workspace = 2;
          "Mod+Shift+3".move-window-to-workspace = 3;
        };
      };
    };
  };
}
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
          "Mod+Return" = {
            _props.hotkey-overlay-title = "Terminal";
            spawn = ["kitty" "-e" "fish"];
          };

          "Mod+Shift+O".open-overview = {};

          "Mod+Shift+E" = {
            quit = {};
          };

          "Mod+S" = {
            consume-window-into-column = {};
          };

          "Mod+Shift+S" = {
            expel-window-from-column = {};
          };

          "Mod+Space" = {
            spawn = ["noctalia" "msg" "panel-open" "launcher"];
          };

          "Mod+Shift+4" = {
            spawn = ["noctalia" "msg" "screenshot-region"];
          };

          "Mod+Q" = {close-window = {};};
          "Mod+F" = {maximize-column = {};};
          "Mod+Shift+F" = {fullscreen-window = {};};
          "Mod+Shift+Space" = {toggle-window-floating = {};};

          "Mod+H".focus-column-left = {};
          "Mod+L".focus-column-right = {};
          "Mod+K".focus-window-or-workspace-up = {};
          "Mod+J".focus-window-or-workspace-down = {};

          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;

          "Mod+Shift+1".move-window-to-workspace = 1;
          "Mod+Shift+2".move-window-to-workspace = 2;
          "Mod+Shift+3".move-window-to-workspace = 3;
        };
      };
    };
  };
}

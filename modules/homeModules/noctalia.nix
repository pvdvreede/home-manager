{...}: {
  flake.homeModules.noctalia = {pkgs, ...}: {
    programs.noctalia = {
      enable = true;
      package = pkgs.noctalia;
      systemd.enable = true;
      checkConfig = true;

      settings = {
        bar.default = {
          background_opacity = 0.0;
          capsule = true;
          capsule_padding = 12.0;
          capsule_thickness = 1.0;
          center = ["workspaces"];
          end = [
            "media"
            "tray"
            "clipboard"
            "volume"
            "brightness"
            "battery"
            "network"
            "group:g1"
            "group:g2"
            "session"
          ];
          margin_edge = 3;
          margin_ends = 2;
          margin_opposite_edge = 3;
          padding = 23;
          position = "top";
          scale = 1.0;
          shadow = false;
          start = [
            "launcher"
            "sysmon"
          ];
          thickness = 25;

          monitor = {
            dp2 = {
              match = "DP-2";
              scale = 1.4;
            };
          };

          capsule_group = [
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "g1";
              members = [
                "date"
                "clock"
              ];
              opacity = 1.0;
              padding = 12.0;
            }
            {
              accordion = false;
              accordion_direction = "end";
              enabled = true;
              fill = "surface_variant";
              id = "g2";
              members = [
                "notifications"
                "control-center"
              ];
              opacity = 1.0;
              padding = 12.0;
            }
          ];
        };

        desktop_widgets = {
          enabled = false;
        };

        idle = {
          behavior_order = [
            "lock"
            "screen-off"
            "lock-and-suspend"
          ];
          behavior = {
            lock = {
              action = "lock";
              enabled = true;
              timeout = 360.0;
            };
            screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 120.0;
            };
            lock-and-suspend = {
              action = "lock_and_suspend";
              enabled = false;
              timeout = 900.0;
            };
          };
        };

        location = {
          address = "Melbourne, Australia";
        };

        lockscreen_widgets = {
          enabled = false;
          schema_version = 2;
          widget_order = [
            "lockscreen-login-box@eDP-1"
            "lockscreen-login-box@DP-2"
          ];

          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };

          widget = {
            "lockscreen-login-box@DP-2" = {
              box_height = 196.0;
              box_width = 810.0;
              cx = 1920.0;
              cy = 1978.0;
              output = "DP-2";
              rotation = 0.0;
              type = "login_box";

              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = true;
                show_weather = true;
              };
            };

            "lockscreen-login-box@eDP-1" = {
              box_height = 196.0;
              box_width = 810.0;
              cx = 768.0;
              cy = 682.0;
              output = "eDP-1";
              rotation = 0.0;
              type = "login_box";

              settings = {
                background_color = "surface_variant";
                background_opacity = 0.88;
                background_radius = 12.0;
                center_password_text = false;
                input_opacity = 1.0;
                input_radius = 6.0;
                layout = "regular";
                show_caps_lock = true;
                show_keyboard_layout = true;
                show_login_button = true;
                show_media = true;
                show_session_buttons = true;
                show_unlock_hint = true;
                show_weather = true;
              };
            };
          };
        };

        shell = {
          font = "JetBrainsMono Nerd Font";
          launch_apps_as_systemd_services = true;

          animation = {
            speed = 1.1;
          };

          panel = {
            open_near_click_control_center = true;
          };
        };

        system.monitor = {
          cpu_poll_seconds = 10;
          gpu_poll_seconds = 10;
          memory_poll_seconds = 10;
          network_poll_seconds = 10;
        };

        theme = {
          mode = "light";
          source = "wallpaper";
          wallpaper_scheme = "m3-tonal-spot";
        };

        wallpaper = {
          directory = "~/Pictures/Wallpapers";
          default = {
            path = "${pkgs.noctalia}/share/noctalia/assets/noctalia-wallpaper.png";
          };
          last = {
            path = "${pkgs.noctalia}/share/noctalia/assets/noctalia-wallpaper.png";
          };
        };

        widget.media = {
          enabled = false;
        };

        widget.launcher = {
          glyph = "brand-denodo";
        };
      };
    };
  };
}

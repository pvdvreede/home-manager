{...}: {
  flake.homeModules.i3 = {pkgs, ...}: {
    xsession.windowManager.i3 = {
      enable = true;
      config = let
        mod = "Mod1";
      in {
        gaps = {
          "inner" = 15;
          "outer" = 15;
        };

        bars = [];

        keybindings = {
          # Killing windows
          "${mod}+Shift+q" = "kill";

          # Changing focus
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          # Moving windows
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # Layout modes
          "${mod}+h" = "split h";
          "${mod}+v" = "split v";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+a" = "focus parent";

          # Workspaces (1-10)
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";

          # Moving windows to workspaces
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace 5";
          "${mod}+Shift+6" = "move container to workspace 6";

          # Scratchpad
          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+minus" = "scratchpad show";

          # i3 Management
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'yes' 'i3-msg exit'";

          "${mod}+space" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun";
          "${mod}+return" = "exec --no-startup-id ${pkgs.kitty}/bin/kitty";
        };
      };
    };
  };

  flake.nixosModules.i3-rdp = {pkgs, ...}: let
    startI3Safe = pkgs.writeShellScript "start-i3-safe" ''
      #!/usr/bin/env bash
      set -euo pipefail

      export XDG_SESSION_TYPE=x11
      export DESKTOP_SESSION=i3
      export DONT_PROMPT_WSL_INSTALL=yes
      export GDK_BACKEND=x11

      # Ensure HOME is set (XRDP sometimes runs with a minimal env)
      if [ -z "${"HOME:-"}" ]; then
        HOME="$(getent passwd "$(id -un)" | cut -d: -f6)"
        export HOME
      fi

      # On XRDP, DISPLAY should be like :10, :11, etc.
      # If an i3 instance is already managing this DISPLAY, i3-msg will be able to talk to it.
      if ${pkgs.i3}/bin/i3-msg -t get_version >/dev/null 2>&1; then
        # i3 is already running for this DISPLAY. Do a soft restart so the session remains usable.
        ${pkgs.i3}/bin/i3-msg -t command restart >/dev/null 2>&1 || true

        # Keep the XRDP session alive (otherwise start script exits immediately).
        exec ${pkgs.xterm}/bin/xterm -title 'i3 (already running) — XRDP session' || exec ${pkgs.coreutils}/bin/sleep infinity
      else
        # No i3 managing this DISPLAY yet — start a fresh session.
        exec ${pkgs.i3}/bin/i3
      fi
    '';
  in {
    # Graphics, Window Manager (i3), and RDP (XRDP)
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
      displayManager = {
        # We don't need a local DM inside WSL; xrdp will launch our WM.
        # Leave DMs disabled; XRDP will call our start script.
        lightdm.enable = false;
      };
    };

    services.displayManager = {
      sddm.enable = false;
      gdm.enable = false;
      # Optional: default session naming if you later decide to use a DM.
      defaultSession = "none+i3";
    };

    services.xrdp = {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "${startI3Safe}";
    };
  };
}

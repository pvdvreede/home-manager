{...}: {
  # Idle dispatch for the Wayland session.
  #
  # This is a *user* service: idle detection needs WAYLAND_DISPLAY and the
  # compositor's ext-idle-notify-v1 protocol, neither of which exist in the
  # system context. swayidle is protocol-based (not niri-specific) and works on
  # any compositor implementing ext-idle-notify-v1 (niri, sway, hyprland, ...).
  #
  # Split of responsibilities:
  #   - power *policy* (suspend decision, idle timing) lives in
  #     nixosModules.power-management and is reached through the
  #     `laptop-power` helper at /run/current-system/sw/bin/laptop-power.
  #   - screen-off / lock are compositor/shell-specific "cosmetics" and are
  #     supplied by the compositor/shell modules via the options below, so
  #     swapping niri/Noctalia only means re-pointing these strings.
  flake.homeModules.idle = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.powerIdle = {
      screenOffCommand = lib.mkOption {
        type = lib.types.str;
        default = "true";
        description = "Command run at the screen-off idle timeout.";
      };
      screenOffResumeCommand = lib.mkOption {
        type = lib.types.str;
        default = "true";
        description = "Command run on activity after the screen was switched off.";
      };
      lockCommand = lib.mkOption {
        type = lib.types.str;
        default = "true";
        description = "Command run at the lock idle timeout.";
      };
    };

    config.services.swayidle = {
      enable = true;
      timeouts = [
        # Screen off after 2 minutes.
        {
          timeout = 120;
          command = config.powerIdle.screenOffCommand;
          resumeCommand = config.powerIdle.screenOffResumeCommand;
        }
        # Lock after 6 minutes.
        {
          timeout = 360;
          command = config.powerIdle.lockCommand;
        }
        # Suspend to RAM after 20 min idle (s2idle on AC, S3 on battery; the
        # mode is selected by nixosModules.power-management).
        {
          timeout = 1200;
          command = "/run/current-system/sw/bin/laptop-power idle-suspend";
        }
      ];
    };
  };
}

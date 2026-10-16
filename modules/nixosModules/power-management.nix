{...}: {
  # System-wide laptop power policy. Deliberately compositor- and
  # shell-agnostic: nothing here depends on niri, Noctalia, or any Wayland
  # session. The session layer only *triggers* these actions (see
  # modules/homeModules/idle.nix); the decisions (AC vs battery, lid behaviour,
  # governor/profile) live here.
  flake.nixosModules.power-management = {pkgs, ...}: let
    # Stable entry point for session-level idle handlers, so swapping
    # compositor/shell never touches power policy.
    laptop-power = pkgs.writeShellScriptBin "laptop-power" ''
      set -eu

      # "On AC" if any mains supply or USB-C power-delivery source reports
      # `online`. The XPS 13 charges over USB-C, whose supply has type "USB",
      # so a mains-only check would miss it and wrongly hibernate while plugged
      # in.
      on_ac() {
        for supply in /sys/class/power_supply/*; do
          [ -r "$supply/type" ] || continue
          case "$(cat "$supply/type")" in
            Mains | USB) ;;
            *) continue ;;
          esac
          [ "$(cat "$supply/online" 2>/dev/null || echo 0)" = "1" ] && return 0
        done
        return 1
      }

      case "''${1:-}" in
        on-ac) on_ac ;;
        idle-suspend)
          # On AC: s2idle first (USB keyboard wakes it), then logind
          # auto-hibernates after HibernateDelaySec. That also covers the
          # "started on AC, unplugged while asleep" case -- it still lands in
          # hibernation instead of draining in s2idle.
          if on_ac; then exec ${pkgs.systemd}/bin/systemctl suspend-then-hibernate; fi ;;
        idle-hibernate)
          if on_ac; then :; else exec ${pkgs.systemd}/bin/systemctl hibernate; fi ;;
        *)
          echo "usage: laptop-power {on-ac|idle-suspend|idle-hibernate}" >&2
          exit 2 ;;
      esac
    '';
  in {
    # This XPS 9370's firmware gives xHCI a _PRW that only advertises wake from
    # S0 (`XHC  S0  *enabled` in /proc/acpi/wakeup), so a USB keyboard cannot
    # wake the machine from S3/deep. Use suspend-to-idle instead: it matches the
    # firmware's S0 wake path and is only ever reached on AC (the session layer
    # suspends on AC idle; on battery we hibernate to disk).
    boot.kernelParams = ["mem_sleep_default=s2idle"];

    environment.systemPackages = [laptop-power];

    services.logind = {
      enable = true;
      settings.Login = {
        # Battery: lid close => hibernate (suspend-to-disk, near-zero power).
        HandleLidSwitch = "hibernate";
        # On AC with no external display: ignore the lid.
        HandleLidSwitchExternalPower = "ignore";
        # Docked / external display attached: ignore the lid. logind checks
        # "docked" (docking station OR >1 display) BEFORE external power, so
        # this is what makes clamshell + dock work.
        HandleLidSwitchDocked = "ignore";
        KillUserProcesses = false;
      };
    };

    services.power-profiles-daemon.enable = false;
    services.thermald.enable = true;
    services.upower.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        # AC = performance.
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        PLATFORM_PROFILE_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;

        # Battery = power saving.
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        # XPS 9370 exposes: cool quiet balanced performance (no "low-power").
        PLATFORM_PROFILE_ON_BAT = "quiet";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;

        # Battery health.
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 90;

        # Keep USB controllers armed on AC so a docked/attached keyboard can
        # wake the machine; allow power saving on battery.
        USB_AUTOSUSPEND_ON_AC = 0;
        USB_AUTOSUSPEND_ON_BAT = 1;
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

    services.udev.extraRules = ''
      # Wake from suspend via a USB keyboard, directly attached or docked.
      # Enable wakeup on the xHCI controller and on every USB device whose
      # ID_USB_INTERFACES contains a HID interface (:03????: = class 03).
      # ID_USB_INTERFACES is produced by the usb_id builtin, so import it
      # explicitly to be order-independent.
      ACTION=="add", SUBSYSTEM=="pci", DRIVERS=="xhci_hcd", ATTR{power/wakeup}="enabled"
      ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", IMPORT{builtin}="usb_id", ENV{ID_USB_INTERFACES}=="*:03????:*", ATTR{power/wakeup}="enabled"
    '';

    systemd.sleep.settings.Sleep = {
      SuspendState = "mem";
      AllowHibernation = "yes";
      # Suspend first, then hibernate automatically after HibernateDelaySec.
      # Resuming normally (e.g. USB keyboard) before then cancels the timer.
      AllowSuspendThenHibernate = "yes";
      HibernateDelaySec = "10min";
    };
  };
}

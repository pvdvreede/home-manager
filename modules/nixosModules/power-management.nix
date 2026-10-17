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
      # so a mains-only check would miss it and wrongly pick S3 while plugged
      # in.
      # Use shell builtins (no cat) so this works under a systemd unit's
      # minimal PATH as well as from the session.
      on_ac() {
        for supply in /sys/class/power_supply/*; do
          [ -r "$supply/type" ] || continue
          local ty; ty="$(<"$supply/type")"
          case "$ty" in
            Mains | USB) ;;
            *) continue ;;
          esac
          local on=0
          [ -r "$supply/online" ] && on="$(<"$supply/online")"
          [ "$on" = "1" ] && return 0
        done
        return 1
      }

      # Report the currently selected /sys/power/mem_sleep mode (the value
      # between [ ]).
      current_mem_sleep() {
        local line; read -r line < /sys/power/mem_sleep
        line="''${line#*[}"
        line="''${line%%]*}"
        printf '%s' "$line"
      }
      # Idempotent: only write when the requested mode differs, and only accept
      # the modes this firmware exposes.
      set_mem_sleep() {
        case "$1" in
          s2idle | deep) ;;
          *) echo "bad mem_sleep mode: $1" >&2; exit 2 ;;
        esac
        [ "$(current_mem_sleep)" = "$1" ] || echo "$1" > /sys/power/mem_sleep
      }

      case "''${1:-}" in
        on-ac) on_ac ;;
        set-mem-sleep)
          # Battery => deep (S3); AC => s2idle (matches the firmware's S0 wake
          # path so a USB keyboard can wake it).
          if on_ac; then set_mem_sleep s2idle; else set_mem_sleep deep; fi ;;
        idle-suspend)
          # Suspend to RAM. The low-level mode (s2idle on AC, deep/S3 on
          # battery) is already set by set-mem-sleep.
          exec ${pkgs.systemd}/bin/systemctl suspend ;;
        *)
          echo "usage: laptop-power {on-ac|set-mem-sleep|idle-suspend}" >&2
          exit 2 ;;
      esac
    '';
  in {
    # This XPS 9370's firmware gives xHCI a _PRW that only advertises wake from
    # S0 (`XHC  S0  *enabled` in /proc/acpi/wakeup), so a USB keyboard cannot
    # wake the machine from S3/deep. On AC we therefore use suspend-to-idle
    # (s2idle), matching the firmware's S0 wake path. On battery we use S3/deep
    # instead, accepting that only the lid (LID0 S3) or power button (PBTN S3)
    # can wake it. The mode is selected at runtime by mem-sleep-mode.service;
    # this kernel param is just the deterministic AC-friendly boot default.
    boot.kernelParams = ["mem_sleep_default=s2idle"];

    environment.systemPackages = [laptop-power];

    services.logind = {
      enable = true;
      settings.Login = {
        # Battery, no external display: lid close => suspend to RAM. The mode
        # is deep on battery and s2idle on AC (selected by mem-sleep-mode).
        HandleLidSwitch = "suspend";
        # On AC with no external display: ignore the lid (precedence: this
        # short-circuits HandleLidSwitch, so AC lid-close does nothing).
        HandleLidSwitchExternalPower = "ignore";
        # Docked / external display attached: ignore the lid. logind checks
        # "docked" (docking station OR >1 display) BEFORE external power, so
        # this is what makes clamshell + dock work.
        HandleLidSwitchDocked = "ignore";
        # Honour the compositor/shell "lock before sleep" delay inhibitor
        # instead of suspending immediately (logind defaults to ignoring it).
        LidSwitchIgnoreInhibited = "no";
        KillUserProcesses = false;
      };
    };

    services.power-profiles-daemon.enable = false;
    services.thermald.enable = true;
    services.upower = {
      enable = true;
      # Hibernation is disabled, so the only safe critical action is to
      # power off. Only fires while awake.
      criticalPowerAction = "PowerOff";
    };

    # Select /sys/power/mem_sleep by power source: deep on battery, s2idle on
    # AC. Re-runs at boot (multi-user.target) and on every power-supply
    # add/change uevent below, so it follows plug/unplug live.
    systemd.services.mem-sleep-mode = {
      description = "Select /sys/power/mem_sleep by power source (deep on battery, s2idle on AC)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${laptop-power}/bin/laptop-power set-mem-sleep";
      };
      # At boot the firmware/ucsi PD stack emits a burst of power_supply
      # add/change events (AC + three ucsi sources), each pulling this unit in
      # via SYSTEMD_WANTS. That exceeds systemd's default 5-starts/10s and left
      # the unit in `failed (start-limit-hit)`, so later plug/unplug events were
      # rejected until the limit expired. The run is idempotent and cheap, so
      # disable rate limiting entirely.
      unitConfig.StartLimitIntervalSec = 0;
      wantedBy = ["multi-user.target"];
    };

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

      # Select mem_sleep on plug/unplug. Restrict to supplies with type
      # Mains/USB so battery capacity uevents don't spam the service; TAG+="systemd"
      # is required for SYSTEMD_WANTS to be honoured.
      ACTION=="add|change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains|USB", TAG+="systemd", ENV{SYSTEMD_WANTS}+="mem-sleep-mode.service"
    '';

    systemd.sleep.settings.Sleep = {
      SuspendState = "mem";
      # Hibernation is disabled entirely; suspend to RAM only.
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
      AllowHybridSleep = "no";
    };
  };
}

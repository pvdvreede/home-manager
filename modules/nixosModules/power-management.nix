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

      case "''${1:-}" in
        idle-suspend)
          # Suspend-to-idle (see SuspendState=freeze below).
          exec ${pkgs.systemd}/bin/systemctl suspend ;;
        on-ac)
          # "On AC" if any mains supply or USB-C power-delivery source reports
          # `online`. The XPS 13 charges over USB-C, whose supply has type
          # "USB", so a mains-only check would miss it.
          # Use shell builtins (no cat) so this works under systemd's minimal
          # PATH as well as from the session.
          for supply in /sys/class/power_supply/*; do
            [ -r "$supply/type" ] || continue
            case "$(<"$supply/type")" in
              Mains | USB) ;;
              *) continue ;;
            esac
            [ -r "$supply/online" ] && [ "$(<"$supply/online")" = "1" ] && exit 0
          done
          exit 1 ;;
        *)
          echo "usage: laptop-power {on-ac|idle-suspend}" >&2
          exit 2 ;;
      esac
    '';
  in {
    # This XPS 9370's firmware gives xHCI a _PRW that only advertises wake from
    # S0 (`XHC  S0  *enabled` in /proc/acpi/wakeup) and exposes no AC-adapter or
    # EC wake source at S3, so from S3/deep only the lid (LID0) and power button
    # (PBTN) can wake it — a USB keyboard or a charger plug-in cannot.
    # Suspend-to-idle is therefore used unconditionally: S0 wake paths stay live,
    # so plugging in power (AC / ucsi PD, both `power/wakeup=enabled`) or pressing
    # a USB key wakes the machine. Cost: higher standby drain on battery than S3.
    boot.kernelParams = ["mem_sleep_default=s2idle"];

    environment.systemPackages = [laptop-power];

    services.logind = {
      enable = true;
      settings.Login = {
        # Battery, no external display: lid close => suspend to idle.
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
      # Root hubs gate xhci's per-port wake bits. xhci_bus_suspend() programs
      # PORT_WKCONN_E on *empty* ports only when device_may_wakeup(root hub) is
      # true; otherwise it clears PORT_WAKE_BITS for the whole controller. The
      # root hubs default to disabled, so without this a plug into an empty
      # port (re-attaching the dock to a lid-closed, sleeping laptop) can never
      # wake the machine -- only LID0/PBTN do. bDeviceClass 09 = hub, which is
      # the root hubs plus the dock's internal hubs.
      ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{bDeviceClass}=="09", ATTR{power/wakeup}="enabled"

      # Charger plug-in is a wake event: arm the AC adapter and the USB-C PD
      # (ucsi) supplies as wake sources. The kernel already defaults these to
      # enabled; set explicitly so a driver or firmware change can't silently
      # drop plug-to-wake. Only Mains/USB types, so battery uevents stay inert.
      ACTION=="add", SUBSYSTEM=="power_supply", ATTR{type}=="Mains|USB", ATTR{power/wakeup}="enabled"
    '';

    systemd.sleep.settings.Sleep = {
      # "freeze" = suspend-to-idle explicitly, independent of mem_sleep.
      SuspendState = "freeze";
      # Hibernation is disabled entirely; suspend to RAM only.
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
      AllowHybridSleep = "no";
    };
  };
}

{...}: {
  # System-wide laptop power policy. Deliberately compositor- and
  # shell-agnostic: nothing here depends on niri, Noctalia, or any Wayland
  # session. The session layer only *triggers* these actions (see
  # modules/homeModules/idle.nix); the decisions (AC vs battery, lid behaviour,
  # governor/profile) live here. The same helper also runs the battery guard
  # that powers the machine off when it would otherwise die suspended.
  flake.nixosModules.power-management = {pkgs, ...}: let
    # s2idle freezes userspace (and CLOCK_MONOTONIC), so nothing can sample the
    # fuel gauge while asleep. A suspended laptop on battery would therefore
    # drain to 0%. Instead we arm an RTC wake alarm for every suspend on
    # battery: it wakes the machine every `suspendCheckSeconds`, the guard
    # samples the battery, then either powers off or goes straight back to
    # sleep. Each wake costs ~1-3s awake; that is the price of the check.
    suspendCheckSeconds = 600;
    batteryShutdownPercent = 30;

    # Shared by every entry point below. Bash builtins only (no cat) so this
    # also works under systemd's minimal PATH.
    powerHelpers = ''
      power_supply_online() {
        # "On AC" if any mains supply or USB-C power-delivery source reports
        # `online`. The XPS 13 charges over USB-C, whose supply has type
        # "USB", so a mains-only check would miss it.
        for supply in /sys/class/power_supply/*; do
          [ -r "$supply/type" ] || continue
          case "$(<"$supply/type")" in
            Mains | USB) ;;
            *) continue ;;
          esac
          [ -r "$supply/online" ] && [ "$(<"$supply/online")" = "1" ] && return 0
        done
        return 1
      }

      battery_percent() {
        # Lowest charge across all batteries; empty output if there is none.
        # Only BAT*: hidpp_battery_0 (a mouse) is type Battery too.
        local lowest=
        local supply cap
        for supply in /sys/class/power_supply/BAT*; do
          [ -r "$supply/capacity" ] || continue
          cap=$(<"$supply/capacity")
          case "$cap" in "" | *[!0-9]*) continue ;; esac
          if [ -z "$lowest" ] || [ "$cap" -lt "$lowest" ]; then
            lowest=$cap
          fi
        done
        printf '%s\n' "$lowest"
      }

      lid_closed() {
        local state
        for state in /proc/acpi/button/lid/*/state; do
          [ -r "$state" ] || continue
          case "$(<"$state")" in
            *closed*) return 0 ;;
            *open*) return 1 ;;
          esac
        done
        # No lid switch: never assume the machine is unattended.
        return 1
      }

      external_display() {
        # Docked means an output other than the internal panel is connected.
        local status output
        for status in /sys/class/drm/card*-*/status; do
          [ -r "$status" ] || continue
          output=''${status%/status}
          output=''${output##*/}
          output=''${output#*-}
          case "$output" in eDP*) continue ;; esac
          [ "$(<"$status")" = "connected" ] && return 0
        done
        return 1
      }
    '';

    # Stable entry point for session-level idle handlers, so swapping
    # compositor/shell never touches power policy.
    laptop-power = pkgs.writeShellScriptBin "laptop-power" ''
      set -eu

      ${powerHelpers}

      case "''${1:-}" in
        idle-suspend)
          # Suspend-to-idle (see SuspendState=freeze below).
          exec ${pkgs.systemd}/bin/systemctl suspend ;;
        on-ac)
          if power_supply_online; then exit 0; else exit 1; fi ;;
        suspend-arm)
          # Run before every sleep. Only a battery-powered suspend can strand
          # the machine. A suspend entered on AC is left unarmed: charger
          # plug-in is a wake source (see the udev rules below), so it wakes
          # itself. Known gap: unplugging after an AC suspend is not a
          # guaranteed wake source, so that suspend drains unguarded.
          # The timer is stopped on AC, so "armed" means "battery suspend in
          # flight" and a stale alarm cannot survive a resume.
          if power_supply_online; then
            ${pkgs.systemd}/bin/systemctl stop laptop-power-wake.timer
            exit 0
          fi
          exec ${pkgs.systemd}/bin/systemctl restart laptop-power-wake.timer ;;
        suspend-check)
          # Run when the wake alarm fires. Nothing cancels the alarm on a manual
          # resume, so it can also elapse while the machine is awake: every
          # decision is re-derived from current state, never from the arm time.
          if power_supply_online; then
            ${pkgs.systemd}/bin/systemctl stop laptop-power-wake.timer
            exit 0
          fi

          # Only an unattended machine is guarded: lid closed and nothing but
          # the internal panel connected. A docked or opened machine is in use,
          # so never power it off from here (upower handles its own threshold)
          # and never force it back to sleep. The delay lets DRM hotplug settle
          # after the wake, so a docked machine is not mistaken for a closed one.
          ${pkgs.coreutils}/bin/sleep 3
          lid_closed || exit 0
          external_display && exit 0

          cap=$(battery_percent)
          case "$cap" in
            "" | *[!0-9]*)
              # No usable reading: do not power off on a guess.
              ${pkgs.util-linux}/bin/logger -t laptop-power \
                "no battery capacity reading, leaving power decisions to the rest of the policy" ;;
            *)
              if [ "$cap" -lt ${toString batteryShutdownPercent} ]; then
                ${pkgs.util-linux}/bin/logger -t laptop-power \
                  "battery at ''${cap}%, powering off"
                # --no-block: this unit must not wait on the shutdown it asked
                # for, nor hold a oneshot job open with no timeout.
                exec ${pkgs.systemd}/bin/systemctl --no-block poweroff
              fi ;;
          esac

          # Re-arm before suspending so this cycle cannot end up unarmed; the
          # pre-sleep unit re-arms again, which only re-bases the deadline.
          ${pkgs.systemd}/bin/systemctl restart laptop-power-wake.timer
          exec ${pkgs.systemd}/bin/systemctl --no-block suspend ;;
        *)
          echo "usage: laptop-power {on-ac|idle-suspend|suspend-arm|suspend-check}" >&2
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

    # Battery guard across suspend (see laptop-power above).
    #
    # `laptop-power-sleep` is pulled in by sleep.target and is Before it, so the
    # alarm is armed just before the machine freezes. It is a plain oneshot (no
    # RemainAfterExit): every sleep cycle starts it again, so no ExecStop and no
    # disarm/re-arm ordering is involved. `suspend-arm` stops the timer on AC and
    # `suspend-check` stops it when the alarm finds the machine on AC, so "armed"
    # always means a battery suspend is in flight and no stale alarm survives a
    # resume. Known gap: a suspend entered on AC and then unplugged carries no
    # alarm, because unplug is not a guaranteed wake source.
    #
    # `laptop-power-wake.timer` has no WantedBy on purpose: it is started only
    # by suspend-arm. OnActiveSec counts from that start, and WakeSystem=yes
    # makes systemd use CLOCK_BOOTTIME_ALARM, so the interval keeps counting
    # while the machine is asleep and the RTC alarm actually fires.
    systemd.services.laptop-power-sleep = {
      description = "Arm the low-battery wake alarm before sleep";
      wantedBy = ["sleep.target"];
      before = ["sleep.target"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${laptop-power}/bin/laptop-power suspend-arm";
      };
    };

    systemd.services.laptop-power-wake = {
      description = "Sample the battery after the suspend wake alarm";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${laptop-power}/bin/laptop-power suspend-check";
      };
    };

    systemd.timers.laptop-power-wake = {
      description = "Periodic wake from suspend to check the battery";
      timerConfig = {
        OnActiveSec = toString suspendCheckSeconds;
        AccuracySec = "1s";
        WakeSystem = true;
        RemainAfterElapse = false;
        Unit = "laptop-power-wake.service";
      };
    };

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
        STOP_CHARGE_THRESH_BAT0 = 100;

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

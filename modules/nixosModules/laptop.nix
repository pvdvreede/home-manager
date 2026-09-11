{...}: {
  flake.nixosModules.laptop = {...}: {
    services.logind = {
      enable = true;
      settings = {
        Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchDocked = "ignore";
          KillUserProcesses = false;
        };
      };
    };

    services.power-profiles-daemon.enable = false;
    services.thermald.enable = true;
    services.upower.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 50; # 40 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 90; # 80 and above it stops charging

        # Explicitly control autosuspend behavior based on the power source:
        # 1 = enabled (allow power saving / suspension)
        # 0 = disabled (always awake / no power saving)
        USB_AUTOSUSPEND_ON_AC = 0;
        USB_AUTOSUSPEND_ON_BAT = 1;

        # Control Runtime Power Management for the underlying USB controllers
        # "auto" = allows suspension/power down
        # "on"   = prevents suspension (always on)
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

    services.udev.extraRules = ''
      # Allow USB keyboards and mice to wake the system from suspend
      ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTR{power/wakeup}="enabled"
    '';

    systemd.sleep.settings.Sleep = {
      SuspendState = "mem";
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
    };
  };
}

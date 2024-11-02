{pkgs, ...}: {
  home.packages = [pkgs.killall pkgs.polybar];

  home.file = {
    config = {
      target = ".config/polybar/config.ini";
      source = ./config.ini;
    };

    script = {
      target = ".config/polybar/launch.sh";
      executable = true;
      text = ''
        #!/usr/bin/env bash

        killall -q polybar
        for m in $(polybar --list-monitors | cut -d":" -f1); do
          MONITOR=$m polybar --reload &
        done
      '';
    };
  };

  # manually setup if we dont want it to be a service
  # services.polybar = {
  #   enable = true;
  #   config = {
  #     "bar/top" = {
  #       width = "98%";
  #       height = "2%";
  #       radius = 0;
  #       modules-center = "date";
  #     };

  #     "module/date" = {
  #       type = "internal/date";
  #       internal = 5;
  #       date = "%d.%m.%y";
  #       time = "%H:%M";
  #       label = "%time%  %date%";
  #     };
  #   };
  #   script = ''
  #     killall -q polybar
  #     polybar top &
  #   '';
  # };
}

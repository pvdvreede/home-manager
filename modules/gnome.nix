{ ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";
      enable-hot-corners = true;
      clock-show-weekday = true;
      clock-show-date = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      speed = -0.610;
      natural-scroll = false;
    };
    "org/gnome/desktop/session" = {
      idle-delay = 300;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-ac-timeout = (60 * 60 * 2);
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-schedule-automatic = false;
      night-light-schedule-from = 19.0;
      night-light-schedule-to = 7.0;
      night-light-temperature = 3000;
    };
    "org/gnome/shell" = {
      enabled-extensions =
        [ "pano@elhan.io" "Vitals@CoreCoding.com" "forge@jmmaranan.com" "blur-my-shell@aunetx"];
    };
    "org/gnome/shell/extensions/forge" = {
      window-gap-hidden-on-single = false;
      window-gap-size = 8;
      window-gap-size-increment = 2;
      workspace-skip-tile = "";
    };
    "org/gtk/settings/file-chooser" = {
      clock-format = "24h";
    };
    "org/gnome/desktop/screensaver" = {
      lock-enabled = true;
      lock-delay = 360;
    };
  };
}

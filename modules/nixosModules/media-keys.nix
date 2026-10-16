{...}: {
  # Compositor/shell-agnostic media & brightness keys.
  #
  # actkbd reads the evdev devices directly (started per device by udev), so
  # these keys work under any Wayland compositor, under X11, and on a bare TTY,
  # and they cover every attached keyboard (internal *and* external).
  #
  # IMPORTANT: do NOT also bind these keys in the compositor (niri `binds`,
  # Hyprland, sway, ...). actkbd does not grab the device, so the compositor
  # still sees the keys; adding a bind there too would run the action TWICE.
  #
  # actkbd runs as root. `wpctl` (PipeWire) and `playerctl` (MPRIS over the
  # session D-Bus) are per-user session services, so they are wrapped to run as
  # the login user with the session environment. `brightnessctl` needs root and
  # runs directly.
  flake.nixosModules.media-keys = {
    pkgs,
    config,
    ...
  }: let
    user = "pvdvreede";

    # Bridge from the root actkbd daemon into the user's PipeWire/D-Bus session.
    #
    # The uid is resolved at RUNTIME (id -u), not at eval time: the account is
    # declared without an explicit `uid`, so `config.users.users.<name>.uid` is
    # `null` during evaluation and `toString null` yields an empty string — which
    # silently produced XDG_RUNTIME_DIR=/run/user/ and DBUS_SESSION_BUS_ADDRESS
    # =unix:path=/run/user//bus, making every wpctl call fail.
    session = pkgs.writeShellScript "media-keys-session-run" ''
      uid="$(${pkgs.coreutils}/bin/id -u ${user})"
      runtime="/run/user/$uid"
      exec ${pkgs.util-linux}/bin/runuser -u ${user} -- ${pkgs.coreutils}/bin/env \
        XDG_RUNTIME_DIR="$runtime" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
        "$@"
    '';

    wpctl = "${session} ${pkgs.wireplumber}/bin/wpctl";
    playerctl = "${session} ${pkgs.playerctl}/bin/playerctl";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight";
  in {
    services.actkbd = {
      enable = true;
      bindings = [
        # Volume / mute (evdev: 113=mute, 114=vol-, 115=vol+)
        {
          keys = [113];
          events = ["key"];
          command = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        }
        {
          keys = [114];
          events = ["key" "rep"];
          command = "${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-";
        }
        {
          keys = [115];
          events = ["key" "rep"];
          command = "${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        }
        # Mic mute (248=MICMUTE)
        {
          keys = [248];
          events = ["key"];
          command = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        }
        # Media transport (163=next, 164=play-pause, 165=previous, 166=stop)
        {
          keys = [164];
          events = ["key"];
          command = "${playerctl} play-pause";
        }
        {
          keys = [163];
          events = ["key"];
          command = "${playerctl} next";
        }
        {
          keys = [165];
          events = ["key"];
          command = "${playerctl} previous";
        }
        {
          keys = [166];
          events = ["key"];
          command = "${playerctl} stop";
        }
        # Screen brightness (224=brightnessdown, 225=brightnessup)
        {
          keys = [224];
          events = ["key" "rep"];
          command = "${brightnessctl} set 5%-";
        }
        {
          keys = [225];
          events = ["key" "rep"];
          command = "${brightnessctl} set 5%+";
        }
      ];
    };

    environment.systemPackages = [pkgs.brightnessctl pkgs.playerctl];
  };
}

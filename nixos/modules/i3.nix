{pkgs, ...}: let
  randomWallpaper = import ../pkgs/random-wallpaper.nix pkgs;
in {
  environment.systemPackages = [randomWallpaper];
  services.xserver = {
    enable = true;

    windowManager.i3 = {enable = true;};

    xautolock = {
      enable = true;
      time = 10;
      extraOptions = ["-corners 00+0" "-detectsleep"];
      locker = "${pkgs.i3}/bin/i3lock -i $HOME/.config/wallpaper/random-blurred.png & sleep 60 && xset dpms force off";
    };
  };
}

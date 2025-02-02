{ pkgs, ... }:

{
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.experimental-features = "nix-command flakes";
  environment.shells = [ pkgs.fish pkgs.elvish ];
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      AppleICUForce24HourTime = true;
      "com.apple.swipescrolldirection" = false;
    };

    dock.autohide = true;
    dock.mru-spaces = false;
    dock.autohide-delay = 0.2;
    dock.wvous-tl-corner = 2; # mission control
    dock.wvous-br-corner = 13; # lock the screen
    finder._FXShowPosixPathInTitle = true;
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.CreateDesktop = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    menuExtraClock = {
      Show24Hour = true;
      ShowDate = 0;
      ShowDayOfMonth = true;
      ShowDayOfWeek = true;
    };
  };

  system.startup.chime = false;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

}

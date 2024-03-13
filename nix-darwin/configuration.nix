{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.experimental-features = "nix-command flakes";
  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;
  system.defaults = {
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
    };

    dock.autohide = true;
    dock.autohide-delay = 0.2;
    dock.wvous-tl-corner = 2; #mission control
    dock.wvous-br-corner = 13; #lock the screen
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.CreateDesktop = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    trackpad.Clicking = true;

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

  # make sure homebrew is pre-installed for this to work
  # TODO: is there a hook to run install command?
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";

    casks = [
      "amethyst"
    ];

    # for apps that are not allowed to run, use here with no-quarantine
    extraConfig =
    ''
      cask "alacritty", args: { "no-quarantine": true }
    '';
  };
}

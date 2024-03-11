{ ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.experimental-features = "nix-command flakes";
  programs.fish.enable = true;
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.CreateDesktop = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    trackpad.Dragging = true;

    menuExtraClock = {
      Show24Hour = true;
      ShowDate = 0;
      ShowDayOfMonth = true;
      ShowDayOfWeek = true;
    };
  };
  system.startup.chime = false;
}
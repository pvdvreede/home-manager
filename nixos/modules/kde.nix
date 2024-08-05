{ pkgs, ... }:

{
  services.xserver.desktopManager.plasma5 = { enable = true; };

  environment.systemPackages = with pkgs; [
    plasma5Packages.bismuth
    libsForQt5.bismuth
  ];
}

{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    desktopManager.gnome = {
      enable = true;
    };

    displayManager = {
      defaultSession = "gnome";
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    gnome-terminal
    gnome-music
    epiphany
    gedit
    geary
    tali
    iagno
    hitori
    atomix
  ]);

  environment.systemPackages = with pkgs.gnomeExtensions; [
    forge
    vitals
    pano
    blur-my-shell
  ];
}
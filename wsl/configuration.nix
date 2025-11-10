{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.wget
    pkgs.coreutils # needed for vscode devcontainers
    pkgs.xorg.xinit
    pkgs.terminator
  ];

  # Graphics, Window Manager (i3), and RDP (XRDP)
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xrdp.enable = true;
  services.xrdp.openFirewall = true;

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  virtualisation.docker = {
    enable = true;
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}

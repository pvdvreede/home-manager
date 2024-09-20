{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.wget
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  virtualisation.docker = { enable = true; };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  nix = {
    package = pkgs.nixFlakes;
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

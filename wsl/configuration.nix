{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.wget
    pkgs.coreutils # needed for vscode devcontainers
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  virtualisation.docker = {enable = true;};

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
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

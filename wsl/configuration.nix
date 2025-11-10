{pkgs, ...}: {
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
  services.xrdp.defaultWindowManager = ''
    rm -rf /tmp/.X* /tmp/.X11-unix/*

    export XDG_SESSION_TYPE=x11
    export DISPLAY=:10
    export LIBGL_ALWAYS_INDIRECT=1
    export PATH="${pkgs.i3}/bin:$PATH"

    # Start i3 directly
    # exec ${pkgs.xorg.xinit}/bin/startx
    exec i3
  '';

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  virtualisation.docker = {
    enable = true;
  };

  users.users.nixos = {
    isNormalUser = true;
    hashedPassword = "$6$hepjXE61HxWzfEbl$NF.ujvhEopLv8Ce54mfVuS44g3iUdJ9pD7iUBqOuIPYAjQJ8diQSaqkorNC.ZUJPTdkU0.C9uIG1c/tv.j9qt1";
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

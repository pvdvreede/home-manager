{pkgs, ...}: let
  startI3Safe = pkgs.writeShellScript "start-i3-safe" ''
    #!/usr/bin/env bash
    set -euo pipefail

    export XDG_SESSION_TYPE=x11
    export DESKTOP_SESSION=i3
    export DONT_PROMPT_WSL_INSTALL=yes
    export GDK_BACKEND=x11

    # Ensure HOME is set (XRDP sometimes runs with a minimal env)
    if [ -z "${HOME:-}" ]; then
      HOME="$(getent passwd "$(id -un)" | cut -d: -f6)"
      export HOME
    fi

    # On XRDP, DISPLAY should be like :10, :11, etc.
    # If an i3 instance is already managing this DISPLAY, i3-msg will be able to talk to it.
    if ${pkgs.i3}/bin/i3-msg -t get_version >/dev/null 2>&1; then
      # i3 is already running for this DISPLAY. Do a soft restart so the session remains usable.
      ${pkgs.i3}/bin/i3-msg -t command restart >/dev/null 2>&1 || true

      # Keep the XRDP session alive (otherwise start script exits immediately).
      exec ${pkgs.xterm}/bin/xterm -title 'i3 (already running) — XRDP session' || exec ${pkgs.coreutils}/bin/sleep infinity
    else
      # No i3 managing this DISPLAY yet — start a fresh session.
      exec ${pkgs.i3}/bin/i3
    fi
  '';
in {
  environment.systemPackages = [
    pkgs.wget
    pkgs.coreutils # needed for vscode devcontainers
    pkgs.xorg.xinit
    pkgs.xterm
  ];

  # Graphics, Window Manager (i3), and RDP (XRDP)
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager = {
      # We don't need a local DM inside WSL; xrdp will launch our WM.
      # Leave DMs disabled; XRDP will call our start script.
      lightdm.enable = false;
    };
  };

  services.displayManager = {
    sddm.enable = false;
    gdm.enable = false;
    # Optional: default session naming if you later decide to use a DM.
    defaultSession = "none+i3";
  };

  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "${startI3Safe}";
  };

  programs.nix-ld = {
    enable = true;
    # package = pkgs.nix-ld-rs;
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

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

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

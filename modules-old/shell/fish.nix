{pkgs, ...}: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship.enableFishIntegration = true;
  programs.atuin.enableFishIntegration = true;
  programs.kitty.settings.enableFishIntegration = true;
  programs.kitty.settings.shell = "${pkgs.fish}/bin/fish";

  programs.tmux.shell = "${pkgs.fish}/bin/fish";

  programs.fish = {
    enable = true;
    functions = {
      envsource = {
        body = ''
          for line in (cat $argv | grep -v '^#')
            set item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
            echo "Exported key $item[1]"
          end
        '';
      };
    };
    shellAliases = {
      ll = "ls -lah";
      fig = "docker compose";
      gst = "git status";
      gco = "git checkout";
      ga = "git add";
      gc = "git commit";
      gd = "git diff";
      gdca = "git diff --cached";
      gpom = "git push origin main";
      ns = "nix search nixpkgs";
      nsh = "nix-shell -p";

      hms = "home-manager switch";
      lz = "lazygit";
    };
    shellInit = ''
      # Source nix-daemon for multi-user installations (NixOS, WSL)
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end
    '';
    interactiveShellInit = ''
      if test -e ~/.custom.fish
        source ~/.custom.fish
      end

      # Add nix profiles to PATH
      # This ensures nix-installed binaries take priority
      fish_add_path --global --prepend ~/.nix-profile/bin /nix/var/nix/profiles/default/bin
    '';
  };
}

{
  pkgs,
  nu-scripts,
  ...
}: {
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      completions.external = {
        enable = true;
        max_results = 200;
      };
    };
    configFile = {
      text = ''
        source ${nu-scripts}/custom-completions/aws/aws-completions.nu
        source ${nu-scripts}/custom-completions/docker/docker-completions.nu
        source ${nu-scripts}/custom-completions/git/git-completions.nu
        source ${nu-scripts}/custom-completions/jj/jj-completions.nu
        source ${nu-scripts}/custom-completions/just/just-completions.nu
        source ${nu-scripts}/custom-completions/zoxide/zoxide-completions.nu
        source ${nu-scripts}/custom-completions/nix/nix-completions.nu

        alias ll = ls -la
        alias fig = docker compose
        alias k = kubectl
        alias hms = home-manager switch
        alias ns = nix search nixpkgs
        alias nsh = nix-shell -p
      '';
    };
  };

  programs.starship.enableNushellIntegration = true;
  programs.atuin.enableNushellIntegration = true;
  programs.zoxide.enableNushellIntegration = true;

  programs.tmux.shell = "${pkgs.nushell}/bin/nu";

  programs.vscode.profiles.default.userSettings = {
    "terminal.integrated.defaultProfile.osx" = "nu";
    "terminal.integrated.defaultProfile.linux" = "nu";
    "terminal.integrated.profiles.osx" = {
      nu = {
        path = "${pkgs.nushell}/bin/nu";
        args = [];
      };
    };
    "terminal.integrated.profiles.linux" = {
      nu = {
        path = "${pkgs.nushell}/bin/nu";
        args = [];
      };
    };
  };
}

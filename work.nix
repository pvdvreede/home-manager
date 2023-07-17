{ pkgs, ... }:

{
  home.file = {
    wezterm = {
      enable = true;
      executable = false;
      source = ./wezterm.lua;
      target = ".wezterm.lua";
    };
  };

  home.packages = with pkgs; [
    kubectl
    istioctl
    kubernetes-helm
    awscli
    kind
    saml2aws
  ];

  programs.k9s = {
    enable = true;
    settings = {
      k9s = {
        logger = {
          textWrap = true;
          sinceSeconds = 6000;
        };
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      hashicorp.terraform
      redhat.vscode-yaml
      ms-azuretools.vscode-docker
      # ms-vscode-remote.remote-containers
    ];
    userSettings = {
      "editor.tabSize" = 2;
      "files.trimTrailingWhitespace" = true;
      "editor.fontSize" = 14;
      "files.autoSave" = "onFocusChange";
      "editor.fontFamily" = "'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
    };
  };

  programs.fish = {
    shellAliases = {
      k = "kubectl";
    };
  };
}

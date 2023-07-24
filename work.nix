{ pkgs, vscode-marketplace, ... }:

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
    awscli
    istioctl
    jq
    kind
    kubectl
    kubernetes-helm
    saml2aws
    step-cli
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
    extensions = with vscode-marketplace; [
      adamhartford.vscode-base64
      bbenoist.nix
      catppuccin.catppuccin-vsc
      hashicorp.terraform
      johnpapa.vscode-peacock
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      oderwat.indent-rainbow
      redhat.vscode-yaml
    ];
    userSettings = {
      "editor.tabSize" = 2;
      "files.trimTrailingWhitespace" = true;
      "editor.fontSize" = 14;
      "terminal.integrated.fontSize" = 14;
      "files.autoSave" = "onFocusChange";
      "editor.fontFamily" = "'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "workbench.colorTheme" = "Catppuccin Mocha";
      "editor.wordWrap" = "on";
    };
    userTasks = {};
    keybindings = [
      {
        key = "ctrl+shift+d";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+k";
        command = "editor.action.deleteLines";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+up";
        command = "editor.action.moveLinesUpAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+down";
        command = "editor.action.moveLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
    ];
  };

  programs.fish = {
    shellAliases = {
      k = "kubectl";
    };
  };
}

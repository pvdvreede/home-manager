{ pkgs, ... }:

{
  home.file = {
    wezterm = {
      enable = true;
      executable = false;
      source = ./wezterm.lua;
      target = ".wezterm.lua";
    };

    zshrc = {
      enable = true;
      executable = true;
      text = ''
      #! /bin/sh

      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      fish
      '';
      target = ".zshrc";
    };
  };

  home.packages = with pkgs; [
    awscli2
    istioctl
    jq
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

  programs.fish = {
    shellAliases = {
      k = "kubectl";
      sa = "saml2aws";
    };
    interactiveShellInit = ''
    complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
    '';
  };
}

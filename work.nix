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

  programs.fish = {
    shellAliases = {
      k = "kubectl";
    };
  };
}

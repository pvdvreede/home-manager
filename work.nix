{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    istioctl
    kubernetes-helm
    awscli
    saml2aws
  ];
  programs.k9s = {
    enable = true;
    settings = {
      logger = {
        textWrap = true;
      };
    };
  };
  programs.fish = {
    shellAliases = {
      k = "kubectl";
    };
  };
}

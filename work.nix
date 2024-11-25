{pkgs, ...}: {
  home.packages = with pkgs; [
    awscli2
    istioctl
    jq
    kubectl
    kubernetes-helm
    saml2aws
    step-cli
    docker-compose
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

}

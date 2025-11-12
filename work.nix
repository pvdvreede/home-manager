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
    docker-client
    podman
    lima
  ];
}

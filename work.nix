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

  programs.fish = {
    shellAliases = {
      k = "kubectl";
      sa = "saml2aws";
    };
    interactiveShellInit = ''
      complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'

      fish_add_path --global --append /opt/homebrew/bin /opt/homebrew/sbin
    '';
  };
}

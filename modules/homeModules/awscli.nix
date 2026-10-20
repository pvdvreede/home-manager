{...}: {
  flake.homeModules.awscli = {...}: {
    programs.awscli = {
      enable = true;
    };
  };
}

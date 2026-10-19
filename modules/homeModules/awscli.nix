{...}: {
  flake.homeModules.awscli = {...}: {
    programs.awscli = {
      enable = true;
      settings = {
        "default" = {
          region = "ap-southeast-2";
          output = "json";
        };
      };
    };
  };
}

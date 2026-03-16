{...}: {
  flake.homeModules.gh = {pkgs, ...}: {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        # Workaround for https://github.com/nix-community/home-manager/issues/4744
        version = 1;
      };
    };
  };
}

{...}: {
  flake.nixosModules.docker = {...}: {
    virtualisation.docker = {
      enable = true;
    };

    users.users."pvdvreede".extraGroups = ["docker"];
  };
}

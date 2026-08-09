{...}: {
  flake.homeModules.lima = {
    pkgs,
    lib,
    ...
  }: let
    limaDockerYaml =
      (pkgs.formats.yaml {}).generate "lima-docker.yaml"
      (lib.recursiveUpdate (import ./_vms/base.nix)
        (import ./_vms/docker.nix));
    limaPodmanYaml =
      (pkgs.formats.yaml {}).generate "lima-podman.yaml"
      (lib.recursiveUpdate (import ./_vms/base.nix)
        (import ./_vms/podman.nix));
    limaDebianYaml =
      (pkgs.formats.yaml {}).generate "lima-debian.yaml"
      (lib.recursiveUpdate (import ./_vms/base.nix)
        (import ./_vms/debian.nix));
  in {
    home.packages = with pkgs; [
      lima
      docker
      docker-compose
    ];

    home.sessionVariables = {
      DOCKER_HOST = "unix://$HOME/.lima/docker/sock/docker.sock";
    };

    home.file.".lima/docker/lima.yaml".source = limaDockerYaml;
    home.file.".lima/podman/lima.yaml".source = limaPodmanYaml;
    home.file.".lima/debian/lima.yaml".source = limaDebianYaml;
  };
}

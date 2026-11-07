{...}: {
  flake.homeModules.oh-my-pi = {
    lib,
    pkgs,
    ...
  }: let
    # Base configuration for oh-my-pi (`omp`, the pi fork). Nix owns the
    # package, so omp must not fetch its own updates; everything else stays at
    # upstream defaults until a host overrides it in its own omp config.
    settings = {
      startup.quiet = true;
      startup.checkUpdate = false;
    };
    configFile = (pkgs.formats.yaml {}).generate "omp-config.yml" settings;
  in {
    home.packages = [pkgs.omp];

    # omp rewrites ~/.omp/agent/config.yml at runtime and takes an advisory
    # flock on it first. A `home.file` symlink into the Nix store is read-only,
    # so the lock and the atomic rewrite fail with EACCES. Copy a writable
    # regular file instead; declared values win again on the next switch.
    # Add further keys to `settings` above (see `omp config --help`).
    home.activation.ohMyPiConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p "$HOME/.omp/agent"
      run install -m 600 ${configFile} "$HOME/.omp/agent/config.yml"
    '';
  };
}

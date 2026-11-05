{lib, ...}: {
  flake.homeModules.zerostack = {
    pkgs,
    config,
    lib,
    ...
  }: let
    version = "1.8.5";

    # Prebuilt binaries from the upstream GitHub release. nixpkgs has no
    # zerostack package, so this pins the tarball and its hash per system.
    sources = {
      aarch64-darwin = {
        file = "zerostack-aarch64-apple-darwin.tar.gz";
        hash = "sha256-wyfEAVu3Rpq5ZRmhN3om9QUpwuw9an0RqlEsQHcNKbA=";
      };
      x86_64-darwin = {
        file = "zerostack-x86_64-apple-darwin.tar.gz";
        hash = "sha256-CUk/9vHydP6J8jcegPaHiuTYf9wZ03s6t5eKnCYRusc=";
      };
      aarch64-linux = {
        file = "zerostack-aarch64-unknown-linux-musl.tar.gz";
        hash = "sha256-qE6vz1oqyllqa7Ep1hO0DHHmkAKSACH3V3k1lBo0MN0=";
      };
      x86_64-linux = {
        file = "zerostack-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-t9cb3KhUm/AO8jB9+D5mhFqVY5+mC8k7FV+Fg+e1Jvg=";
      };
    };

    system = pkgs.stdenv.hostPlatform.system;
    supported = builtins.hasAttr system sources;

    package = pkgs.stdenvNoCC.mkDerivation {
      pname = "zerostack";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/gi-dellav/zerostack/releases/download/v${version}/${sources.${system}.file}";
        hash = sources.${system}.hash;
      };

      # The release archive is a tarball that holds a single binary at its root
      # (no top-level directory), so unpack it by hand.
      dontUnpack = true;

      nativeBuildInputs = [pkgs.gzip];

      installPhase = ''
        runHook preInstall
        tar xzf $src
        install -Dm755 zerostack "$out/bin/zerostack"
        runHook postInstall
      '';

      meta = {
        description = "Minimal coding agent written in Rust, optimized for memory footprint and performance";
        homepage = "https://github.com/gi-dellav/zerostack";
        license = lib.licenses.gpl3Only;
        mainProgram = "zerostack";
        platforms = lib.attrNames sources;
      };
    };
  in {
    options.programs.zerostack = {
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        example = {
          provider = "openrouter";
          model = "deepseek/deepseek-v4-flash";
          compact_enabled = true;
          permission.read = "allow";
        };
        description = ''
          Config written to `config.toml`. Keys are passed through to zerostack
          unchanged (see https://github.com/gi-dellav/zerostack/blob/main/docs/CONFIG.md).
          Empty by default, so no file is written and zerostack creates its own.
        '';
      };
    };

    config = lib.mkMerge [
      # Only install on systems with a pinned upstream binary.
      {home.packages = lib.optional supported package;}

      (lib.mkIf (config.programs.zerostack.settings != {}) {
        # zerostack resolves the config directory with `dirs::config_dir()`,
        # which on macOS is ~/Library/Application Support rather than $XDG_CONFIG_HOME.
        # Pointing ZS_CONFIG_DIR at the XDG path keeps one file layout on every host.
        home.sessionVariables.ZS_CONFIG_DIR = "${config.xdg.configHome}/zerostack";

        xdg.configFile."zerostack/config.toml".source =
          (pkgs.formats.toml {}).generate "config.toml" config.programs.zerostack.settings;
      })
    ];
  };
}

{...}: {
  flake.homeModules.oh-my-pi = {
    lib,
    pkgs,
    ...
  }: let
    # Base configuration for oh-my-pi (`omp`, the pi fork). Nix owns the
    # package, so omp must not fetch its own updates; everything else stays at
    # upstream defaults until a host overrides it in its own omp config.
    # billion-context: context-compression proxy injected as an omp native
    # extension. `dist/` is a self-contained esbuild bundle (only optional
    # mysql2/jimp/ws extras are external), so the npm tarball alone suffices —
    # no npm install at build or activation time. The extension spawns its own
    # proxy via a Node runtime (not Bun), hence nodejs below, and cancels
    # omp's auto-compaction while it owns the session (auto_compaction_* +
    # session_before_compact hooks), so both never compress the same turn.
    billion-context = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "billion-context";
      version = "0.1.212";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/billion-context/-/billion-context-${finalAttrs.version}.tgz";
        hash = "sha256-dnKU4MjDwulEy8zky4WDqotw4bg8VW/I/afTdY/gTus=";
      };

      dontBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/node_modules/billion-context
        cp -r dist package.json $out/lib/node_modules/billion-context/
        runHook postInstall
      '';
    });

    # Nix owns these; they always win over whatever the live config says.
    managedSettings = {
      startup.quiet = true;
      startup.checkUpdate = false;
      extensions = [
        "${billion-context}/lib/node_modules/billion-context/dist/agent/omp-native.js"
      ];
    };

    # Seed values only: written where the live config has no value for the key,
    # so `omp config set <key>` still wins. Model roles and the thinking level
    # are here on purpose — pick a different model or level per task and it
    # sticks across switches.
    defaultSettings = {
      modelRoles.default = "deepseek/deepseek-flash";
      defaultThinkingLevel = "low";
      theme.dark = "titanium";
      symbolPreset = "nerd";
      composer.shape = "band";
      hideThinkingBlock = true;
    };

    managedFile = (pkgs.formats.yaml {}).generate "omp-managed.yml" managedSettings;
    defaultFile = (pkgs.formats.yaml {}).generate "omp-defaults.yml" defaultSettings;

    # `--inplace` only ever writes the first input, so both merges run here and
    # the result replaces config.yml atomically via a same-directory rename.
    mergeScript = pkgs.writeShellScript "omp-config-merge" ''
      set -eu
      cfg="$1"
      managed="$2"
      defaults="$3"
      work="$cfg.work"
      trap 'rm -f "$work" "$work.merged"' EXIT

      if [ -f "$cfg" ]; then cp "$cfg" "$work"; else cp "$managed" "$work"; fi

      # 1. Managed keys win.
      ${pkgs.yq-go}/bin/yq eval-all --inplace \
        '. as $item ireduce ({}; . * $item)' "$work" "$managed"

      # 2. Defaults fill only what is still absent (`*` keeps the right-hand
      # value, so the live config wins over the defaults file).
      ${pkgs.yq-go}/bin/yq eval-all \
        '. as $item ireduce ({}; . * $item)' "$defaults" "$work" > "$work.merged"

      chmod 600 "$work.merged"
      mv "$work.merged" "$cfg"
    '';
  in {
    home.packages = [pkgs.omp pkgs.nodejs];

    # omp rewrites ~/.omp/agent/config.yml at runtime and takes an advisory
    # flock on it first. A `home.file` symlink into the Nix store is read-only,
    # so the lock and the atomic rewrite fail with EACCES. Keep a writable
    # regular file and merge into it on every switch:
    #
    #   managedSettings  always win   (extensions = nix-store path, no self-update)
    #   defaultSettings  fill gaps    (model role, thinking level, appearance)
    #   everything else               whatever omp itself persisted
    #
    # A plain copy would drop every undeclared key — including `setupVersion`,
    # whose absence re-arms omp's first-run setup wizard. Arrays are replaced,
    # not appended. Dropping a key from `defaultSettings` does not unset it; run
    # `omp config reset <key>` once and the merge preserves that.
    home.activation.ohMyPiConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p "$HOME/.omp/agent"
      run ${mergeScript} "$HOME/.omp/agent/config.yml" ${managedFile} ${defaultFile}
    '';
  };
}

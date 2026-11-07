{...}: {
  flake.homeModules.herdr-app = {
    config,
    lib,
    pkgs,
    ...
  }: let
    homeDir = config.home.homeDirectory;
    # Third-party mods and layouts, pulled from their own repos at activation.
    # Bump `rev` (tag, branch or sha) to take an upstream change.
    #
    #   kind = "mod"     -> copied to herdr-app/mods/<name>
    #   kind = "layout"  -> copied to herdr-app/layouts/<name>.json
    #
    # `subdir` is the path of the mod or layout inside the repo.
    pulled = {
      git-graph = {
        url = "https://github.com/rabeeh-ta/herdr-git-graph";
        rev = "v0.3.1";
        subdir = "mods/git-graph";
      };
    };

    # Local mods committed in this repo (clones of shipped mods with edits).
    local = ["tabs-deepseek"];
  in {
    # The herdr-app desktop app keeps its whole UI as plain files in
    # $XDG_CONFIG_HOME/herdr-app (JSON, see ~/.config/herdr-app/AGENTS.md).
    # Only user-owned files are linked here. Everything else in that directory
    # is written or replaced by the app itself:
    #
    #   rewritten every start: AGENTS.md, herdr.d.ts, gpui-kit.d.ts, icons/,
    #     frame/, update-notes*, layouts/main.json, layouts/terminals.json,
    #     layouts/win98.json, and every shipped mods/<name>/ directory
    #   written at runtime: view.json, window.json, shared.json, seen.json,
    #     installed.json, data/, telemetry/, layouts/.state/
    #
    # Do not add those paths here. To change a shipped layout or mod, clone it
    # first and link the clone instead:
    #
    #   herdr-app do layout.clone '{"name":"main","as":"my-layout"}'
    #   herdr-app do mod.clone '{"name":"files","as":"my-files"}'
    #
    # These links are immutable, so in-app changes that write back to a linked
    # file do not persist. That affects settings.json (zoom, theme, font,
    # option_as_alt) and keys.json. Edit files/ here and switch instead.
    #
    # Mods and layouts added below are copied in whole by an activation script,
    # never linked. A mod's `./module.js` import is checked against the mod's own
    # folder, and a symlink resolves to /nix/store, so the app refuses it
    # (`module './graph.js' resolves outside the application directory`).
    #
    # Check a copied mod after switching:
    #
    #   herdr-app check ~/.config/herdr-app/mods/<name>
    home.activation.herdrAppMods = lib.hm.dag.entryAfter ["linkGeneration"] (
      ''
        export GIT_TERMINAL_PROMPT=0
        run mkdir -p "${homeDir}/.config/herdr-app/mods" "${homeDir}/.config/herdr-app/layouts"
        run mkdir -p "${homeDir}/.cache/herdr-app-src"
      ''
      + lib.concatMapStrings (name: let
        entry = pulled.${name};
        dest =
          if (entry.kind or "mod") == "layout"
          then "${homeDir}/.config/herdr-app/layouts/${name}.json"
          else "${homeDir}/.config/herdr-app/mods/${name}";
        url = lib.escapeShellArg entry.url;
        rev = lib.escapeShellArg entry.rev;
        cache = "${homeDir}/.cache/herdr-app-src/${name}-${lib.replaceStrings ["/"] ["-"] entry.rev}";
        cacheArg = lib.escapeShellArg cache;
        srcArg = lib.escapeShellArg "${cache}/${entry.subdir}";
      in ''
        if [[ ! -d ${cacheArg} ]]; then
          run ${pkgs.git}/bin/git init -q ${cacheArg}
          run ${pkgs.git}/bin/git -C ${cacheArg} remote add origin ${url}
          run ${pkgs.git}/bin/git -C ${cacheArg} fetch -q --depth 1 origin ${rev}
          run ${pkgs.git}/bin/git -C ${cacheArg} -c advice.detachedHead=false checkout -q FETCH_HEAD
        fi
        run rm -rf ${lib.escapeShellArg dest}
        run cp -R ${srcArg} ${lib.escapeShellArg dest}
        run chmod -R u+w ${lib.escapeShellArg dest}
      '')
      (builtins.attrNames pulled)
      + lib.concatMapStrings (name: let
        dest = "${homeDir}/.config/herdr-app/mods/${name}";
        destArg = lib.escapeShellArg dest;
      in ''
        run rm -rf ${destArg}
        run cp -R ${./files/mods + "/${name}"} ${destArg}
        run chmod -R u+w ${destArg}
      '')
      local
    );

    xdg.configFile = {
      "herdr-app/settings.json".source = ./files/settings.json;
      "herdr-app/keys.json".source = ./files/keys.json;
      "herdr-app/layouts/main-deepseek.json".source = ./files/layouts/main-deepseek.json;
      "herdr-app/themes/atom-one-dark.json".source = ./files/themes/atom-one-dark.json;
      "herdr-app/themes/win98.json".source = ./files/themes/win98.json;
      "herdr-app/mods/workspace-status-deepseek/mod.json".source = ./files/mods/workspace-status-deepseek/mod.json;
      "herdr-app/mods/workspace-status-deepseek/main.js".source = ./files/mods/workspace-status-deepseek/main.js;
    };
  };
}

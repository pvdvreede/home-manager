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
      github = {
        url = "https://github.com/mrolafsson/herdr-github";
        rev = "v0.11.0";
        subdir = "app/mods/github";
      };
    };

    # Local mods committed in this repo (clones of shipped mods with edits).
    # `tabs-panels` is the shipped `tabs` mod plus Git/GitHub panel toggles;
    # `workspace-status-deepseek` is `workspace-status` plus the DeepSeek
    # balance/billing segment.
    local = ["tabs-panels" "workspace-status-deepseek"];

    # Mods this module used to copy in under another name. Removed on activation
    # so a rename does not leave a stale copy in ~/.config/herdr-app/mods.
    staleLocal = ["tabs-deepseek"];

    # Appended to pi's system prompt (see APPEND_SYSTEM.md below).
    piPromptAppend = ''
      # herdr-app

      - Your terminal runs herdr-app when the environment variable
        `HC_TERMINAL_ID` is set.
      - Then read `~/.config/herdr-app/AGENTS.md` before you interact with
        herdr-app. That file gives the config layout and the `herdr-app do`
        commands.
      - Do not read that file when `HC_TERMINAL_ID` is not set.
    '';
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
    # Local mods added below are copied in whole by an activation script, never
    # linked: a mod's `./module.js` import is checked against the mod's own
    # folder, and a symlink resolves to /nix/store, so the app refuses it
    # (`module './graph.js' resolves outside the application directory`).
    # layouts/personal.json is linked like the other layouts: a layout is JSON
    # with no module resolution, so a symlink is fine.
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
      # Old local-mod names, removed after the current ones are in place.
      + lib.concatMapStrings (name: ''
        run rm -rf ${lib.escapeShellArg "${homeDir}/.config/herdr-app/mods/${name}"}
      '')
      staleLocal
    );

    # pi appends ~/.pi/agent/APPEND_SYSTEM.md to its system prompt. The
    # pi-coding-agent module links that file to its own prompt file, so force
    # the link to a combined file here instead. Nothing is added when pi is
    # not installed.
    home.file.".pi/agent/APPEND_SYSTEM.md".source = lib.mkIf (config.programs.pi-coding-agent.enable or false) (
      lib.mkForce (pkgs.writeText "APPEND_SYSTEM.md" (
        builtins.readFile ../pi-coding-agent/append-system-prompt.md
        + "\n"
        + piPromptAppend
      ))
    );

    xdg.configFile = {
      "herdr-app/settings.json".source = ./files/settings.json;
      "herdr-app/keys.json".source = ./files/keys.json;
      "herdr-app/layouts/personal.json".source = ./files/layouts/personal.json;
      "herdr-app/themes/atom-one-dark.json".source = ./files/themes/atom-one-dark.json;
      "herdr-app/themes/win98.json".source = ./files/themes/win98.json;
    };
  };
}

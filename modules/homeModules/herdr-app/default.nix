{...}: {
  flake.homeModules.herdr-app = {...}: {
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

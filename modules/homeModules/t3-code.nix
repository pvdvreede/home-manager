{...}: {
  flake.homeModules.t3-code = {
    pkgs,
    lib,
    ...
  }: let
    userDataDir = "$HOME/.t3/userdata";

    settings = {
      idleCompaction = "onReturn";
      providerInstances = {
        pi = {
          driver = "pi";
          enabled = true;
        };
      };
    };

    settingsFile = (pkgs.formats.json {}).generate "t3-code-settings.json" settings;
  in {
    # T3 Code writes settings.json itself, so a read-only store symlink would
    # break the in-app Settings page. Deep-merge instead: declared keys win,
    # keys T3 Code persisted on its own are kept.
    home.activation.t3CodeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      dir="${userDataDir}"
      target="$dir/settings.json"
      run mkdir -p "$dir"
      if [ -s "$target" ] && ${pkgs.jq}/bin/jq -e . "$target" >/dev/null 2>&1; then
        tmp="$(mktemp)"
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$target" ${settingsFile} > "$tmp"
        run mv "$tmp" "$target"
      else
        run install -m 644 ${settingsFile} "$target"
      fi
    '';
  };
}

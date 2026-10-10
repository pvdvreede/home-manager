{...}: {
  flake.homeModules.pi-coding-agent = {
    pkgs,
    lib,
    ...
  }: let
    # Extensions authored here and owned by Home Manager. Drop `.ts`/`.js` files
    # (or directories containing `index.ts`) into ./extensions and they are
    # copied into the Nix store and listed by absolute path in settings.json.
    # Pi loads them in place and aliases `@earendil-works/pi-*` and `typebox`,
    # so plain files with no node_modules work.
    #
    # Do NOT also place these under ~/.pi/agent/extensions/: Pi auto-discovers
    # that directory too and would load each one a second time.
    extensionsDir = ./extensions;
    extensions = map (name: extensionsDir + "/${name}") (
      builtins.attrNames (
        lib.filterAttrs
        (name: type: type == "regular" && (lib.hasSuffix ".ts" name || lib.hasSuffix ".js" name))
        (builtins.readDir extensionsDir)
      )
    );
    # System-prompt append (the SYSTEM_APPEND mechanism): Pi reads
    # <configDir>/APPEND_SYSTEM.md and appends it verbatim to its built-in
    # system prompt. Distinct from AGENTS.md, and a project
    # .pi/APPEND_SYSTEM.md overrides this file outright (no concatenation).
    appendSystemPrompt = ./append-system-prompt.md;
  in {
    programs.pi-coding-agent = {
      enable = true;

      # Pi shells out to `npm` to install the `npm:` packages below. nixpkgs
      # already wraps `pi` with ripgrep and fd, so nodejs is the only extra
      # binary required.
      extraPackages = [pkgs.nodejs];

      # Settings (~/.pi/agent/settings.json)
      settings = {
        # Default startup model and thinking level. The DeepSeek API key lives
        # in ~/.pi/agent/auth.json or models.json (see note below), not here.
        defaultProvider = "deepseek";
        defaultModel = "deepseek-flash";
        defaultThinkingLevel = "low";

        # Hide thinking blocks in the transcript by default (`ctrl+t` still
        # toggles them back on at runtime).
        hideThinkingBlock = true;

        # Extensions distributed as npm/git packages. Pi installs these into
        # <configDir>/npm using an explicit `--prefix`, so no writable global
        # npm prefix (and no npmCommand wrapper) is needed. Pin versions
        # (`npm:name@x.y.z`) for reproducible installs.
        packages = [
          # "npm:pi-web-access"
          "npm:pi-web-search"
          "npm:@juicesharp/rpiv-ask-user-question"
        ];

        # Locally authored extensions, owned by Nix. Includes
        # extensions/bash-default-timeout.ts, which injects a 60s `timeout` on
        # every bash call that does not specify one (Pi has no built-in
        # default, so an omitted timeout arms no timer at all).
        inherit extensions;
      };

      # NOTE: `models` is intentionally left unset so Home Manager does not own
      # ~/.pi/agent/models.json. Leave it that way if you want to add providers
      # and API keys by hand: any edits you make there survive `home-manager
      # switch`. Pi reads providers from that file, and keys can either be
      # written inline or referenced as "$OPENCODE_API_KEY" etc.
    };

    # The module has no `appendSystemPrompt` option, so wire the file up by
    # hand. Like settings.json this is a Nix-store symlink, so edits made
    # in-place are lost on the next `home-manager switch`.
    home.file = {
      ".pi/agent/APPEND_SYSTEM.md".source = appendSystemPrompt;
    };
  };
}

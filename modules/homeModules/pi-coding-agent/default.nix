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
    # Skills authored here and owned by Home Manager. Each direct child of
    # ./skills must be a directory containing SKILL.md. Like extensions, they
    # are copied into the Nix store and listed by absolute path in settings.json
    # (settings.skills); Pi loads them in place. Keeping .md data files out of
    # the Nix parser is fine: import-tree only imports modules/**/*.nix.
    skillsDir = ./skills;
    skills = map (name: skillsDir + "/${name}") (
      builtins.attrNames (
        lib.filterAttrs (name: type: type == "directory") (builtins.readDir skillsDir)
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
        # Default startup provider and thinking level. The DeepSeek API key
        # lives in ~/.pi/agent/auth.json or models.json (see note below), not
        # here. `defaultProvider` and `defaultModel` are `mkDefault`/per-host
        # (see modules/hosts/*) so each machine can choose its own startup
        # model without fighting these values.
        defaultProvider = lib.mkDefault "deepseek";
        defaultModel = lib.mkDefault "deepseek-flash";
        defaultThinkingLevel = "low";

        # Hide thinking blocks in the transcript by default (`ctrl+t` still
        # toggles them back on at runtime). The collapsed label still uses the
        # themed `thinkingText` colour, so it stays visually distinct.
        hideThinkingBlock = true;

        # Extensions distributed as npm/git packages. Pi installs these into
        # <configDir>/npm using an explicit `--prefix`, so no writable global
        # npm prefix (and no npmCommand wrapper) is needed.
        #
        # Exact versions (`npm:name@x.y.z`) are pinned: pi's
        # checkForAvailableUpdates() skips pinned sources (see
        # `parsed.pinned` in package-manager.js), so pinning suppresses the
        # "Package Updates Available" notice without having to set PI_OFFLINE
        # — which would also disable model-catalog refresh. Bump these by hand
        # when you want newer extensions.
        packages = [
          "npm:pi-web-search@1.7.0"
          "npm:@juicesharp/rpiv-ask-user-question@2.15.0"
          "npm:billion-context@0.1.208"
          "npm:pi-subagents@0.83.0"
          "npm:pi-file-diff@0.1.8"
        ];

        # Locally authored extensions, owned by Nix.
        inherit extensions;

        # Locally authored skills, owned by Nix. Each entry is a directory
        # containing SKILL.md (see ./skills/plan-stages).
        inherit skills;
      };

      # NOTE: `models` is intentionally left unset so Home Manager does not own
      # ~/.pi/agent/models.json. Leave it that way if you want to add providers
      # and API keys by hand: any edits you make there survive `home-manager
      # switch`. Pi reads providers from that file, and keys can either be
      # written inline or referenced as "$OPENCODE_API_KEY" etc.
    };

    # Nix owns the `pi` package and its lifecycle here, so suppress pi's own
    # "new version available" notice — `pi update` is not how this install is
    # managed. PI_SKIP_VERSION_CHECK only skips the pi.dev latest-version
    # request; it does NOT affect model-catalog refresh. The extension
    # "Package Updates Available" notice is suppressed separately by pinning
    # the `packages` list above, so PI_OFFLINE (which would also disable model
    # refresh) is deliberately NOT set here.

    # The module has no `appendSystemPrompt` option, so wire the file up by
    # hand. Like settings.json this is a Nix-store symlink, so edits made
    # in-place are lost on the next `home-manager switch`.
    home.file = {
      ".pi/agent/APPEND_SYSTEM.md".source = appendSystemPrompt;

      # pi-file-diff config. `ignore` lists directory *names* (case-insensitive,
      # matched anywhere in the tree); `exclude` would take explicit paths.
      # Keep VCS/tooling noise out of the task-end diff receipts.
      ".pi/agent/file-diff.json".text = builtins.toJSON {
        ignore = [
          ".jj"
          ".git"
          "node_modules"
          "result"
          "billion-context"
        ];
      };
    };

    home.sessionVariables.PI_SKIP_VERSION_CHECK = "1";
  };
}

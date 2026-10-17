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
    # Prompt templates authored here and owned by Home Manager. Each direct child
    # of ./prompts must be a Markdown file; its filename becomes the `/` command
    # (e.g. factory.md -> /factory). Listed by absolute store path in
    # settings.prompts, same mechanism as skills.
    promptsDir = ./prompts;
    prompts = map (name: promptsDir + "/${name}") (
      builtins.attrNames (
        lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name) (builtins.readDir promptsDir)
      )
    );

    # System-prompt append (the SYSTEM_APPEND mechanism): Pi reads
    # <configDir>/APPEND_SYSTEM.md and appends it verbatim to its built-in
    # system prompt. Distinct from AGENTS.md, and a project
    # .pi/APPEND_SYSTEM.md overrides this file outright (no concatenation).
    appendSystemPrompt = ./append-system-prompt.md;

    # ---- Thinking-block theme ---------------------------------------------
    # Pi renders BOTH the expanded thinking text and the collapsed
    # "Thinking..." label with the single `thinkingText` theme colour, and
    # paints the per-level thinking indicator with the `thinking*` border
    # colours (see assistant-message.js). Both default to a near-body grey,
    # so thinking is hard to tell apart from normal output. Tint them cyan so
    # thinking is unmistakable in either state.
    #
    # `mdQuote`/`mdQuoteBorder` are also cyan: the `thinking-border` extension
    # wraps expanded thinking in a markdown blockquote (the only way to get a
    # border), and blockquote content is restyled away from `thinkingText` to
    # `mdQuote`/`mdQuoteBorder`.
    #
    # The theme schema requires the full palette, so start from pi's built-in
    # dark theme (read from the installed package) and override only these
    # colours. NOTE: the read path is internal to pi's package layout; if a pi
    # update moves it, this read fails at eval time.
    builtinDarkTheme = builtins.fromJSON (builtins.readFile "${pkgs.pi-coding-agent}/lib/node_modules/pi-monorepo/dist/modes/interactive/theme/dark.json");
    thinkingThemeName = "pvdv";
    thinkingTheme =
      builtinDarkTheme
      // {
        name = thinkingThemeName;
        colors =
          builtinDarkTheme.colors
          // {
            thinkingText = "okhsl(200 70% 72%)";
            thinkingOff = "okhsl(200 25% 55%)";
            thinkingMinimal = "okhsl(200 40% 58%)";
            thinkingLow = "okhsl(200 55% 62%)";
            thinkingMedium = "okhsl(200 65% 66%)";
            thinkingHigh = "okhsl(200 75% 70%)";
            thinkingXhigh = "okhsl(200 85% 74%)";
            thinkingMax = "okhsl(200 95% 78%)";
            mdQuote = "okhsl(200 45% 70%)";
            mdQuoteBorder = "okhsl(200 70% 72%)";
          };
      };
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
        # toggles them back on at runtime). The collapsed label still uses the
        # themed `thinkingText` colour, so it stays visually distinct.
        hideThinkingBlock = true;

        # Custom cyan-tinted thinking theme, written to the themes dir below.
        theme = thinkingThemeName;

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
          # "npm:pi-web-access"
          "npm:pi-web-search@1.7.0"
          "npm:@juicesharp/rpiv-ask-user-question@2.13.9"
          "npm:billion-context@0.1.199"
          "npm:pi-subagents@0.79.0"
          "npm:pi-file-diff@0.1.8"
        ];

        # Locally authored extensions, owned by Nix.
        inherit extensions;

        # Locally authored skills, owned by Nix. Each entry is a directory
        # containing SKILL.md (see ./skills/plan-stages).
        inherit skills;

        # Locally authored prompt templates, owned by Nix. Each entry is a
        # Markdown file whose filename is the `/` command (see ./prompts/factory.md).
        inherit prompts;
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

      # Custom theme for the `theme` setting above. Pi derives the filename
      # from the theme name, hence `thinkingThemeName` in both.
      ".pi/agent/themes/${thinkingThemeName}.json".text = builtins.toJSON thinkingTheme;

      # Herdr's Pi integration. Upstream installs this with
      # `herdr integration install pi`; vendored here so it stays declarative.
      # Pi auto-discovers ~/.pi/agent/extensions/, so this file is deliberately
      # NOT listed in `settings.extensions` above (that would load it twice).
      #
      # The file embeds `HERDR_INTEGRATION_VERSION=<n>`, which
      # `herdr integration status` compares against the Herdr build. After a
      # herdr update, if status reports it outdated, re-vendor by installing to a
      # scratch HOME and copying the file back:
      #   HOME=$(mktemp -d) && mkdir -p "$HOME/.pi/agent"
      #   HOME="$HOME" herdr integration install pi
      #   cp "$HOME/.pi/agent/extensions/herdr-agent-state.ts" \
      #      modules/homeModules/pi-coding-agent/herdr/herdr-agent-state.ts
      # (In-place install is impossible: this path is a read-only store symlink.)
      #
      # LOCAL PATCH: the vendored file uses `source = "pidev:pi"` instead of the
      # upstream `"herdr:pi"`. herdr ignores reports from a built-in integration
      # source unless the reporter owns the pane's tty, so a pi nested inside
      # `devenv shell` never registered. Re-apply after re-vendoring.
      ".pi/agent/extensions/herdr-agent-state.ts".source = ./herdr/herdr-agent-state.ts;
    };

    home.sessionVariables.PI_SKIP_VERSION_CHECK = "1";
  };
}

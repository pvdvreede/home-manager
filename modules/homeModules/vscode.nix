{inputs, ...}: {
  flake.homeModules.vscode = {pkgs, ...}: let
    vscodeSettingsDir =
      if pkgs.system == "aarch64-darwin"
      then "$HOME/Library/Application Support/Code/User"
      else "$HOME/.config/Code/User";
  in {
    programs.vscode = {
      enable = true;
      package = null;
      profiles.default.enableUpdateCheck = false;
      profiles.default.extensions = with inputs.nix-vscode-extensions.extensions.aarch64-darwin.vscode-marketplace; [
        bbenoist.nix
        ms-azuretools.vscode-docker
        ms-vscode.sublime-keybindings
        # ms-vscode-remote.remote-containers
      ];
      profiles.default.userSettings = {
        "editor.tabSize" = 2;
        "files.trimTrailingWhitespace" = true;
        "files.autoSave" = "onFocusChange";
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "editor.lineNumbers" = "relative";
        "editor.formatOnSave" = true;
        "editor.fontSize" = 16;
        "terminal.integrated.fontSize" = 16;
        "workbench.colorTheme" = "Alabaster";
        "workbench.preferredLightColorTheme" = "Alabaster";
        "window.commandCenter" = false;
        "workbench.layoutControl.enabled" = false;
        "workbench.sideBar.location" = "right";
        "editor.fontFamily" = "JetBrains Mono";
        "terminal.integrated.fontFamily" = "JetBrains Mono";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverSettings" = {
          "nil" = {
            "diagnostics" = {"ignored" = [];};
            "formatting" = {"command" = ["${pkgs.alejandra}/bin/alejandra"];};
          };
        };
        "files.readonlyFromPermissions" = true;
        "chat.agent.enabled" = false;
        "chat.disableAIFeatures" = true;
      };
      mutableExtensionsDir = false;
    };

    # The below 2 hooks are added to make the settings json file in vscode writable, as otherwise
    # vscode will constantly throw errors about the settings file having errors.

    # see https://github.com/nix-community/home-manager/issues/1800#issuecomment-1059960604

    # We need to remove the old copied settings.json (from the last home-manager switch) at this point so that home manager
    # does not error with 'an existing file is in the way'.
    home.activation.ignoreAnyExistingVsCodeSettings = {
      after = [];
      before = ["checkLinkTargets"];
      data = ''
        userDir="${vscodeSettingsDir}"
        rm -rf "$userDir/settings.json"
      '';
    };

    # after the settings json is rendered out and symlinked, then we can go in
    # and cat the settings json into a standard file in the VSCode dir.
    home.activation.makeVsCodeSettingsMutable = {
      after = ["writeBoundary"];
      before = [];
      data = ''
        userDir="${vscodeSettingsDir}"
        mv "$userDir/settings.json" "$userDir/settings.ln.json"
        cat "$userDir/settings.ln.json" | ${pkgs.jq}/bin/jq --monochrome-output > "$userDir/settings.json"
        rm -rf "$userDir/settings.ln.json"
      '';
    };
  };
}

{ config, pkgs, vscode-marketplace, ... }:

rec {
  imports = [ ./editing.nix ./dance.nix ./minimalui.nix ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with vscode-marketplace;
      [
        adamhartford.vscode-base64
        hashicorp.terraform
        hashicorp.hcl
        johnpapa.vscode-peacock
        ms-azuretools.vscode-docker
        oderwat.indent-rainbow
        redhat.vscode-yaml
        thenuprojectcontributors.vscode-nushell-lang
        naumovs.color-highlight
        anseki.vscode-color
        jnoortheen.nix-ide
        bierner.markdown-mermaid
        elves.elvish
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "remote-containers";
        publisher = "ms-vscode-remote";
        version = "0.379.0";
        sha256 = "ZXHWwmZDjzdyObpBFAWIML3B8fjByBgIa6Ej5Bm0N/Y=";
      }];
    userSettings = {
      "nix.serverSettings" = {
        "nil" = {
          "diagnostics" = {
            "ignored" = [ ];
          };
          "formatting" = {
            "command" = [ "nixpkgs-fmt" ];
          };
        };
      };
      "files.readonlyFromPermissions" = true;
      "terminal.integrated.profiles.osx" = {
        elvish = {
          path = "${pkgs.elvish}/bin/elvish";
          args = [ ];
        };
      };
      "terminal.integrated.profiles.linux" = {
        elvish = {
          path = "${pkgs.elvish}/bin/elvish";
          args = [ ];
        };
      };
      "terminal.integrated.defaultProfile.osx" = "elvish";
      "terminal.integrated.defaultProfile.linux" = "elvish";
    };
    userTasks = { };
    keybindings = [
      {
        key = "ctrl+shift+d";
        command = "editor.action.copyLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+k";
        command = "editor.action.deleteLines";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+up";
        command = "editor.action.moveLinesUpAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+shift+down";
        command = "editor.action.moveLinesDownAction";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        key = "ctrl+/";
        command = "editor.action.commentLine";
        when = "editorTextFocus && !editorReadonly";
      }
      {
        "key" = "ctrl+shift+a";
        "command" = "workbench.action.terminal.focusNext";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+b";
        "command" = "workbench.action.terminal.focusPrevious";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+j";
        "command" = "workbench.action.togglePanel";
      }
      {
        "key" = "ctrl+shift+n";
        "command" = "workbench.action.terminal.new";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+w";
        "command" = "workbench.action.terminal.kill";
        "when" = "terminalFocus";
      }
      {
        "command" = "workbench.action.toggleSidebarVisibility";
        "key" = "ctrl+e";
      }
      {
        "command" = "workbench.files.action.focusFilesExplorer";
        "key" = "ctrl+e";
        "when" = "editorTextFocus";
      }
      {
        "key" = "n";
        "command" = "explorer.newFile";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "command" = "renameFile";
        "key" = "r";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "key" = "shift+n";
        "command" = "explorer.newFolder";
        "when" = "explorerViewletFocus";
      }
      {
        "command" = "deleteFile";
        "key" = "d";
        "when" = "filesExplorerFocus && !inputFocus";
      }
    ];
  };

  # The below 2 hooks are added to make the settings json file in vscode writable, as otherwise
  # vscode will constantly throw errors about the settings file having errors.

  # see https://github.com/nix-community/home-manager/issues/1800#issuecomment-1059960604

  # We need to remove the old copied settings.json (from the last home-manager switch) at this point so that home manager
  # does not error with 'an existing file is in the way'.
  home.activation.ignoreAnyExistingVsCodeSettings= {
    after = [ ];
    before = [ "checkLinkTargets" ];
    data = ''
      userDir=~/.config/Code/User
      rm -rf $userDir/settings.json
    '';
  };

  # after the settings json is rendered out and symlinked, then we can go in
  # and cat the settings json into a standard file in the VSCode dir.
  home.activation.makeVsCodeSettingsMutable =
    {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        userDir=~/.config/Code/User
        mv $userDir/settings.json $userDir/settings.ln.json
        cat $userDir/settings.ln.json | ${pkgs.jq}/bin/jq --monochrome-output > $userDir/settings.json
        rm -rf $userDir/settings.ln.json
      '';
    };
}

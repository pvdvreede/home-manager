{
  pkgs,
  vscode-marketplace,
  ...
}: let
  vscodeSettingsDir =
    if pkgs.system == "aarch64-darwin"
    then "$HOME/Library/Application Support/Code/User"
    else "$HOME/.config/Code/User";
in {
  imports = [./editing.nix ./theme.nix ./keybindings.nix ./navigation.nix];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.enableUpdateCheck = false;
    mutableExtensionsDir = false;
    profiles.default.extensions = with vscode-marketplace; [
      adamhartford.vscode-base64
      hashicorp.terraform
      hashicorp.hcl
      ms-azuretools.vscode-docker
      oderwat.indent-rainbow
      redhat.vscode-yaml
      naumovs.color-highlight
      anseki.vscode-color
      jnoortheen.nix-ide
      bierner.markdown-mermaid
      ms-vscode-remote.remote-containers
      editorconfig.editorconfig
      ms-azuretools.vscode-containers
    ];
    # if issues reoccur with remote-containers extension
    # then uncomment the below.
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #   {
    #     name = "nix-ide";
    #     publisher = "jnoortheen";
    #     version = "0.3.7";
    #     sha256 = "sha256-Z+e4s+fcpPqxG7IU2E48Jq21FPU+DHHa+VwTEXKiznw=";
    #   }
    # ];
    profiles.default.userSettings = {
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
}

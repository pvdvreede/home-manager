{ lib, ... }:

{
  # https://github.com/nix-community/home-manager/issues/1341
  # Comment used as solution: https://github.com/nix-community/home-manager/issues/1341#issuecomment-901513436
  home.activation = {
    aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      app_folder=$(echo ~/Applications);
      find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
        $DRY_RUN_CMD rm -rf "$app_folder/$(basename "$app")"
        $DRY_RUN_CMD /usr/bin/osascript -e "tell app \"Finder\"" -e "make new alias file to POSIX file \"$(readlink "$app")\" at POSIX file \"$app_folder\"" -e "set name of result to \"$(basename "$app")\"" -e "end tell"
      done
    '';
  };
}

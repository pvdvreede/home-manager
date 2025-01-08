{pkgs, ...}: {
  programs.git = {
    enable = true;
    userEmail = "pvdvreede@gmail.com";
    userName = "pvdvreede";
    ignores = ["#*" "*~" ".DS_Store" ".netrwhist" "*.swp" ".vscode/settings.json"];
    extraConfig = {
      init = {defaultBranch = "main";};
      color = {ui = true;};
      push = {default = "current";};
      branch = {autosetuprebase = "always";};
      rebase = {autosquash = true;};
      pull.rebase = true;
      core.whitespace = "trailing-space";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      # Workaround for https://github.com/nix-community/home-manager/issues/4744
      version = 1;
    };
  };
}

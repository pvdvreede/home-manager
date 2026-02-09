{...}: {
  programs.git = {
    enable = true;
    settings = {
      user.email = "pvdvreede@gmail.com";
      user.name = "pvdvreede";
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
    ignores = ["#*" "*~" ".DS_Store" ".netrwhist" "*.swp" ".direnv"];
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

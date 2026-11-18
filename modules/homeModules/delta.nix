{...}: {
  flake.homeModules.delta = {...}: {
    programs.lazygit.settings.git.diffRenderers = [
      {
        name = "delta";
        command = "delta --paging=never --{{colorScheme}}";
        colorArg = "always";
      }
      {
        type = "rawGit";
        name = "git";
      }
    ];

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = "TwoDark";
        file-style = "omit";
        file-decoration-style = "none";
        hunk-header-style = "file line-number syntax";
        hunk-header-decoration-style = "none";
        commit-decoration-style = "none";
        keep-plus-minus-markers = true;
      };
    };

    programs.git.settings = {
      merge.conflictstyle = "diff3";
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
    };
  };
}

{...}: {
  flake.homeModules.wt = {pkgs, ...}: {
    programs.worktrunk = {
      enable = true;
      settings = {
        skip-shell-integration-prompt = true;
        worktree-path = "~/worktrees/{{ repo }}/{{ branch | sanitize }}";
      };
    };
  };
}

{
  pkgs,
  lib,
  ...
}: {
  programs.opencode = {
    enable = true;

    rules = ''
      ## general development rules
      - when planning a change, optimise for small, easy to review changes. This means trying to split changes across multiple PRs without breaking tests or compilation.
      - assume the use of docker and docker compose to encapsulate all project dependencies regardless of the machine its running on.
      - give me short, concise answers and focus on showing me the code changes rather than explaining it.
    '';

    commands = {
      create-pr = ''
        # create pull request

        generate a new pull request for this work, make sure:
        - main is up-to-date with the origin/main branch
        - this work is on its own branch
        - this work's branch is rebased with main
      '';

      start-fresh = ''
        # start a fresh task

        lets start a fresh task:
        - stash any changed files
        - get main branch up-to-date with the origin/main branch
        - create a new branch, or if the repo is jujutsu enabled, start a fresh change
      '';

      worktree = ''
        ---
        description: Start session in isolated git worktree
        ---
        Create an isolated git worktree for this session and work within it.
        1. Generate a unique worktree name based on the current timestamp and branch: `worktree-$(date +%Y%m%d-%H%M%S)`
        2. Create the worktree in a subdirectory: `mkdir -p .worktrees && git worktree add .worktrees/worktree-<timestamp> -b session/$ARGUMENTS` (use the argument as branch name suffix, or "work" if no argument provided)
        3. IMPORTANT: For ALL subsequent file operations in this session, work in the new worktree directory (.worktrees/worktree-<timestamp>), NOT the original directory
        4. Confirm the worktree was created and tell me the path and branch name
        When the session is complete, remind me to clean up with:
        - `git worktree remove .worktrees/worktree-<name>` (removes worktree)
        - `git branch -d session/<branch>` (deletes branch if merged, or -D to force)
      '';

      worktree-cleanup = ''
        ---
        description: Clean up all git worktrees except current session
        ---
        Clean up all git worktrees that were created for isolated sessions, EXCEPT the one for the current session (if we're working in one).
        Steps:
        1. Run `git worktree list` to see all worktrees
        2. Identify worktrees that match the pattern `.worktrees/worktree-*` (session worktrees)
        3. Determine if we are currently working in a worktree (check if current directory contains ".worktrees/worktree-")
        4. For each session worktree EXCEPT the current one:
           - Run `git worktree remove <path>` to remove the worktree
           - Run `git branch -d session/<branch>` to delete the associated branch (use -D if not merged and user confirms)
        5. Report what was cleaned up and what was preserved
        If $ARGUMENTS contains "all" or "force", also remove the current session's worktree (useful for final cleanup).
        Example output:
        - Removed worktree: .worktrees/worktree-20260127-100000 (branch: session/fix-bug)
        - Removed worktree: .worktrees/worktree-20260126-143022 (branch: session/refactor)
        - Preserved current: .worktrees/worktree-20260127-143022 (branch: session/new-feature)
      '';

      rebase = ''
        ---
        description: rebase branch and update the PR
        ---
        make sure that our current branch is up-to-date.
        run these steps in a sub agent.
        Steps:
        1. update main branch with origin/main branch.
        2. rebase main onto our working branch.
        3. If there are conflicts, review and resolve all of them.
        4. re-run tests and any pre-commit steps, if there are any failures try to fix them.
        5. if there is a current PR for this work, force push the branch to update the PR.
        6. if there is a current PR re-print the URL out.
      '';
    };

    # Global OpenCode configuration
    settings = {
      "$schema" = "https://opencode.ai/config.json";

      # Theme
      theme = "opencode";

      # Auto-update enabled
      autoupdate = true;

      # TUI settings
      tui = {
        scroll_speed = 3;
        scroll_acceleration = {
          enabled = true;
        };
        diff_style = "auto";
      };

      permission = {
        bash = {
          "*" = "ask";
          "git *" = "allow";
          "mkdir *" = "allow";
          "nix *" = "allow";
          "ls *" = "allow";
          "find *" = "allow";
          "grep *" = "allow";
          "docker *" = "allow";
          "docker-compose *" = "allow";
          "devcontainer *" = "allow";
          "jj *" = "allow";
          "echo *" = "allow";
          "limactl *" = "allow";
          "lima *" = "allow";
          "head *" = "allow";
          "tail *" = "allow";
          "make *" = "allow";
          "cat *" = "allow";
          "kill *" = "allow";
          "pkill *" = "allow";
          "sort*" = "allow";
          "sleep *" = "allow";
          "sed *" = "allow";
          "cp *" = "allow";
          "true" = "allow";
          "gh *" = "allow";
          "pwd*" = "allow";
          "date *" = "allow";
          "file *" = "allow";
        };
        edit = "allow";
        grep = "allow";
        task = "allow";
        lsp = "allow";
        read = "allow";
        glob = "allow";
        write = "allow";
        list = "allow";
        skill = "allow";
        # Allow access to all repos cloned via ghq
        external_directory = {
          "~/ghq/**" = "allow";
        };
      };

      # File watcher ignore patterns
      watcher = {
        ignore = [
          "node_modules/**"
          "dist/**"
          ".git/**"
          ".jj/**"
          "target/**"
          "result/**"
        ];
      };
    };
  };
}

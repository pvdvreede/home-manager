---
name: worktrunk
description: Use the Worktrunk `wt` CLI to manage git worktrees, one per branch or PR, so work on several PRs in one repo runs in parallel without stash or branch switches. Use when asked to work on multiple PRs/branches at once, check out a PR for review, isolate concurrent agent writers, or list, clean up, or merge worktrees.
---

# Parallel PR work with Worktrunk (`wt`)

`wt` addresses worktrees by branch name. It computes each path from the
`worktree-path` template in user config. Do not compute paths yourself.

## Agent rules

- Each bash call is a fresh shell. `wt switch` cannot change your directory.
  Always pass `--no-cd`, read the path from `--format json`, then use that path.
- Run commands in a worktree with `cd <path> && ...` or `git -C <path>` or `wt -C <path>`.
- Pass `-y` to skip approval prompts. Never use the interactive picker (`wt switch` with no branch).
- Use `--foreground` with `wt remove` so removal finishes before you continue.
- Do not run `wt merge` or push unless the user asks. Prefer PRs over local merges.
- Never `-D`/`--force` a removal without user approval. These flags discard unmerged work or local changes.
- Requires git >= 2.43. Run `wt --version` if a flag fails; check `wt <cmd> --help`.

## Start work

```sh
# New branch + worktree from the default branch
wt switch -c fix-auth --no-cd -y --format json
# -> {"action":"created","branch":"fix-auth","path":"/…/fix-auth","created_branch":true,"base_branch":"main"}

# New branch from another base (shortcuts: ^ default, @ current, pr:N)
wt switch -c fix-auth-followup --base pr:123 --no-cd -y --format json

# Existing branch (local or origin/<branch>) -> worktree
wt switch feature-x --no-cd -y --format json

# Check out a GitHub PR (fork PRs too; sets pushRemote to the fork)
wt switch pr:123 --no-cd -y --format json
wt switch https://github.com/owner/repo/pull/123 --no-cd -y --format json
```

Capture the path:

```sh
p=$(wt switch pr:123 --no-cd -y --format json | jq -r .path)
cd "$p" && git status
```

If a worktree for the branch exists, `wt switch` reuses it (`"action"` is not `created`).
Use `--clobber` only when a stale directory blocks creation.

## Run a command in a worktree

```sh
wt switch fix-auth --no-cd -y -x sh -- -c 'npm test'
```

`-x` runs in the worktree even with `--no-cd`. Shell syntax needs an explicit `sh -c`.

## Inspect

```sh
wt list                         # table: all worktrees, status, ahead/behind
wt list --format json           # .items[] with .branch, .worktree.path, .worktree.changes
wt list --full                  # adds CI/PR status (slower; needs gh)
wt list --branches --remotes    # include branches without worktrees
wt -C <path> step diff          # all changes since branching
wt step for-each -- git status --short   # run in every worktree
```

## Keep a PR branch current

```sh
cd "$p"
git fetch
wt step rebase           # rebase onto default branch (or: wt step rebase <target>)
git push --force-with-lease
```

Resolve conflicts in that worktree only. Other worktrees are not affected.

## Clean up

```sh
wt remove fix-auth --foreground -y --format json   # removes worktree; deletes branch only if merged
wt remove fix-auth --no-delete-branch --foreground -y
wt step prune --dry-run                            # preview merged worktrees/branches
wt step prune --foreground -y                      # remove them (skips items younger than 1d; --min-age)
```

`wt remove` refuses when the worktree has uncommitted changes or unmerged commits.
Report this to the user. Do not force.

## Multi-PR workflow

1. `wt list --format json` to see existing worktrees.
2. One `wt switch … --no-cd --format json` per PR. Record branch → path.
3. Do all edits, builds, and tests for a PR inside its own path.
4. Commit and push from that path. Open or update the PR with `gh` from that path.
5. After merge, `wt remove <branch> --foreground -y` or `wt step prune --foreground -y`.

For parallel sub-agents: give each writer its own worktree path as `cwd`.
One writer per worktree.

## Notes

- Hooks (`pre-start`, `post-start`, ...) in `.config/wt.toml` may install deps or start servers. Use `--no-hooks` to skip them.
- `wt step copy-ignored` copies gitignored files (for example `.env`, `node_modules`) between worktrees (`--from`, `--to`).
- In a jj repo, prefer `jj workspace` unless the user asks for `wt`. `wt` works on the git backend only.
- Docs: https://worktrunk.dev

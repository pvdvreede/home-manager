local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function current_dir(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return nil
  end
  return cwd.file_path or tostring(cwd)
end

-- The main worktree root, so a linked worktree resolves to the original repo.
local function repo_root(dir)
  if not dir then
    return nil
  end
  local ok, stdout = wezterm.run_child_process({
    "@bash@",
    "-c",
    [[
export PATH=@toolsPath@:$PATH
cd "$1" || exit 1
d=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || exit 1
dirname "$d"
]],
    "sh",
    dir,
  })
  if not ok then
    return nil
  end
  local root = stdout:gsub("%s+$", "")
  return root ~= "" and root or nil
end

-- Names are generated: the worktree branch and the workspace name match.
-- Format: branch wz-<repo name>-<timestamp>, workspace <repo name>-<timestamp>.
-- The repo name comes from the main worktree, so names do not grow when you
-- start from a linked worktree. Git ref rules apply, so reduce the name to
-- lowercase word characters and dashes. Returns branch, workspace.
local function worktree_names(pane)
  local dir = current_dir(pane)
  local path = repo_root(dir) or dir or ""
  local base = path:match("([^/\\]+)[/\\]*$") or "root"
  base = base:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  if base == "" then
    base = "root"
  end
  local stem = string.format("%s-%s", base, os.date("%Y%m%d-%H%M%S"))
  return "wz-" .. stem, stem
end

-- Find the default branch (origin/HEAD, else main, else master).
-- Fetch it from origin, then create the branch and worktree from it.
-- Returns the worktree path, or nil and an error message.
local function create_worktree(dir, branch)
  if not dir then
    return nil, "current directory is unknown"
  end
  -- wezterm.run_child_process takes only an argv list, no cwd option, so the
  -- directory change happens inside the shell. An empty list panics wezterm.
  -- The GUI has no profile PATH, so the tools are absolute store paths.
  local ok, stdout, stderr = wezterm.run_child_process({
    "@bash@",
    "-c",
    [[
export PATH=@toolsPath@:$PATH
cd "$1" || exit 1
b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
b=${b#origin/}
if [ -z "$b" ]; then
  if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
    b=main
  elif git ls-remote --exit-code --heads origin master >/dev/null 2>&1; then
    b=master
  else
    echo "cannot find default branch (main or master) on origin" >&2
    exit 1
  fi
fi
git fetch --quiet origin "$b" && wt switch -c "$2" --base "origin/$b" --no-cd -y --format json
]],
    "sh",
    dir,
    branch,
  })
  if not ok then
    return nil, (stderr ~= "" and stderr or stdout)
  end
  local path = stdout:match('"path"%s*:%s*"(.-)"')
  if not path then
    return nil, "cannot read worktree path from: " .. stdout
  end
  return path
end

-- WezTerm has no "workspace created" event, so creation goes through this
-- keybinding: the worktree is created first, then the panes start in it.
-- Tab 1 is a horizontal split, pi on the left (60%), lazygit on the right
-- (40%). Tab 2 runs the editor.
function M.new_workspace(window, pane)
  local branch, name = worktree_names(pane)
  local dir = current_dir(pane)
  local path, err = create_worktree(dir, branch)

  if not path then
    local _, failed_pane = mux.spawn_window({ workspace = name, cwd = dir })
    mux.set_active_workspace(name)
    failed_pane:send_text("echo " .. shell_quote("worktree failed: " .. err) .. "\r")
    return
  end

  local tab, new_pane, new_window = mux.spawn_window({
    workspace = name,
    cwd = path,
    args = { "@pi@" },
  })
  mux.set_active_workspace(name)

  -- size is the fraction of the new pane: 0.4 lazygit, 0.6 pi.
  new_pane:split({
    direction = "Right",
    size = 0.4,
    cwd = path,
    args = { "@lazygit@" },
  })

  new_window:spawn_tab({ cwd = path, args = { "@hx@", "." } })
  tab:activate()
  new_pane:activate()
end

return M

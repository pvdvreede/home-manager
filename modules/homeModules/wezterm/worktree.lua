local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Run cmd in an interactive login fish. The login config sets the full nix
-- PATH, and fish stays open as the pane shell when cmd exits.
local function in_shell(cmd)
  return { "@fish@", "-l", "-C", cmd }
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
    args = in_shell("@pi@"),
  })
  mux.set_active_workspace(name)

  -- size is the fraction of the new pane: 0.4 lazygit, 0.6 pi.
  new_pane:split({
    direction = "Right",
    size = 0.4,
    cwd = path,
    args = in_shell("@lazygit@"),
  })

  new_window:spawn_tab({ cwd = path, args = in_shell("@hx@ .") })
  tab:activate()
  new_pane:activate()
end

-- The top level of the worktree that holds dir.
local function worktree_root(dir)
  local ok, stdout = wezterm.run_child_process({
    "@bash@",
    "-c",
    [[
export PATH=@toolsPath@:$PATH
cd "$1" && git rev-parse --show-toplevel
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

local function notify(window, msg)
  window:toast_notification("wezterm", msg, nil, 5000)
end

-- Closes every pane in the current workspace, then removes its worktree with
-- wt. The main worktree is never removed. The panes close first, so that no
-- process holds the directory during the removal.
function M.delete_workspace(window, pane)
  local name = window:active_workspace()
  local dir = current_dir(pane)
  local main = repo_root(dir)
  local path = dir and worktree_root(dir)
  if not main or not path then
    notify(window, "not in a git worktree")
    return
  end
  if path == main then
    notify(window, "will not remove the main worktree: " .. path)
    return
  end

  local target = "default"
  for _, ws in ipairs(mux.get_workspace_names()) do
    if ws ~= name then
      target = ws
      break
    end
  end
  window:perform_action(wezterm.action.SwitchToWorkspace({ name = target }), pane)

  local cli = wezterm.executable_dir .. "/wezterm"
  for _, w in ipairs(mux.all_windows()) do
    if w:get_workspace() == name then
      for _, t in ipairs(w:tabs()) do
        for _, p in ipairs(t:panes()) do
          wezterm.run_child_process({ cli, "cli", "kill-pane", "--pane-id", tostring(p:pane_id()) })
        end
      end
    end
  end

  local ok, stdout, stderr = wezterm.run_child_process({
    "@bash@",
    "-c",
    [[
export PATH=@toolsPath@:$PATH
cd "$1" && wt remove --foreground -y "$2"
]],
    "sh",
    main,
    path,
  })
  if not ok then
    notify(window, "wt remove failed: " .. (stderr ~= "" and stderr or stdout))
  end
end

return M

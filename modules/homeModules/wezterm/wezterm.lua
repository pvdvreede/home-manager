local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

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

-- Names are generated: the worktree branch and the workspace name match.
-- Format: branch wz-<dir name>-<timestamp>, workspace <dir name>-<timestamp>.
-- Git ref rules apply, so reduce the dir name to lowercase word characters
-- and dashes. Returns branch, workspace.
local function worktree_names(pane)
  local path = current_dir(pane) or ""
  local base = path:match("([^/\\]+)[/\\]*$") or "root"
  base = base:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  if base == "" then
    base = "root"
  end
  local stem = string.format("%s-%s", base, os.date("%Y%m%d-%H%M%S"))
  return "wz-" .. stem, stem
end

-- Fetch origin/main, then create the branch and worktree from it.
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
    'export PATH=@toolsPath@:$PATH; cd "$1" && git fetch --quiet origin main && wt switch -c "$2" --base origin/main --no-cd -y --format json',
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
local function new_workspace(window, pane)
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
end

-- The leader keys below use these actions, and so does the command palette.
-- Build them once: each action_callback call registers a new event handler.
local new_workspace_action = wezterm.action_callback(new_workspace)
local workspace_picker = wezterm.action.ShowLauncherArgs({
  flags = "FUZZY|WORKSPACES",
  title = "Workspaces",
})

-- WezTerm only adds built-in commands to the command palette, so user
-- bindings need this hook to show up there under a readable brief.
wezterm.on("augment-command-palette", function()
  return {
    {
      brief = "New worktree workspace",
      doc = "Creates a git worktree from origin/main, then opens a workspace for it with pi, lazygit and helix",
      icon = "md_source_branch",
      action = new_workspace_action,
    },
    {
      brief = "Switch workspace",
      doc = "Fuzzy picks an existing workspace",
      icon = "md_view_grid",
      action = workspace_picker,
    },
  }
end)

config.font = wezterm.font("JetBrains Mono")
config.font_size = 16
config.color_scheme = "Tokyo Night"
config.hide_tab_bar_if_only_one_tab = false
config.window_padding = { left = 5, right = 5, top = 5, bottom = 5 }
config.default_cursor_style = "BlinkingBar"

-- Retro tab bar: drawn with the terminal font instead of the fancy GUI style.
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

-- Tab strip sits slightly above the terminal background; the status block
-- keeps the darker Tokyo Night bg_dark so it reads as a separate cell.
config.colors = {
  tab_bar = {
    background = "#1f2335",
    inactive_tab_edge = "#16161e",
    active_tab = {
      bg_color = "#292e42",
      fg_color = "#c0caf5",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1f2335",
      fg_color = "#545c7e",
    },
    inactive_tab_hover = {
      bg_color = "#2b3050",
      fg_color = "#a9b1d6",
    },
  },
  -- Also colours the selected row of the command palette.
  selection_fg = "#c0caf5",
  selection_bg = "#283457",
}

-- Command palette (CTRL+SHIFT+P). It has its own font settings: the family
-- and size do not follow config.font.
config.command_palette_font = wezterm.font("JetBrains Mono")
config.command_palette_font_size = 16
config.command_palette_line_height = 1.4
config.command_palette_rows = 14
config.command_palette_bg_color = "#1a1b26"
config.command_palette_fg_color = "#c0caf5"

-- Draw shortcut key caps with mac symbols (Super, Alt, Ctrl, Shift).
if wezterm.target_triple:find("darwin") then
  config.ui_key_cap_rendering = "AppleSymbols"
end

-- Leader indicator: while the leader key waits for the next key, the right
-- status shows a badge in front of the workspace name.
--
-- Workspace name on the right side of the tab bar.
wezterm.on("update-right-status", function(window, _)
  local cells = {}
  if window:leader_is_active() then
    cells = {
      { Background = { Color = "#7aa2f7" } },
      { Foreground = { Color = "#16161e" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " LEADER " },
    }
  end
  table.insert(cells, { Background = { Color = "#16161e" } })
  table.insert(cells, { Foreground = { Color = "#7aa2f7" } })
  table.insert(cells, { Attribute = { Intensity = "Bold" } })
  table.insert(cells, { Text = " " .. mux.get_active_workspace() .. " " })
  window:set_right_status(wezterm.format(cells))
end)

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

-- Keybinds mirror the tmux config (prefix C-Space).
config.keys = {
  -- project worktree workspace
  { key = "w", mods = "LEADER", action = new_workspace_action },

  -- tmux: split-window -h
  { key = "v", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  -- tmux: split-window -v
  { key = "s", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  -- tmux: new-window
  { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

  -- tmux: vim pane navigation
  { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

  -- tmux window/pane management defaults
  { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  { key = ",", mods = "LEADER", action = wezterm.action.PromptInputLine({
    description = "Rename tab",
    action = wezterm.action_callback(function(window, _, line)
      if line and #line > 0 then
        window:active_tab():set_title(line)
      end
    end),
  }) },

  -- tmux next/previous window
  { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

  -- workspace picker (fuzzy)
  { key = "f", mods = "LEADER", action = workspace_picker },

  -- tmux copy mode
  { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = wezterm.action.ActivateTab(i - 1),
  })
end

return config

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

-- WezTerm has no "workspace created" event, so creation goes through this
-- keybinding and the worktree command runs in the new workspace's pane.
local function new_workspace(window, pane)
  local branch, name = worktree_names(pane)
  local _, new_pane = mux.spawn_window({
    workspace = name,
    cwd = current_dir(pane),
  })
  mux.set_active_workspace(name)

  new_pane:send_text("wt switch -c " .. shell_quote(branch) .. " 2>/dev/null || true\r")
end

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
}

-- Command palette: roomier layout (font family is not configurable here).
config.command_palette_font_size = 16
config.command_palette_rows = 14

-- Workspace name on the right side of the tab bar.
wezterm.on("update-right-status", function(window, _)
  window:set_right_status(wezterm.format({
    { Background = { Color = "#16161e" } },
    { Foreground = { Color = "#7aa2f7" } },
    { Attribute = { Intensity = "Bold" } },
    { Text = " " .. mux.get_active_workspace() .. " " },
  }))
end)

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

-- Keybinds mirror the tmux config (prefix C-Space).
config.keys = {
  -- project worktree workspace
  { key = "w", mods = "LEADER", action = wezterm.action_callback(new_workspace) },

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
  { key = "f", mods = "LEADER", action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES", title = "Workspaces" }) },

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

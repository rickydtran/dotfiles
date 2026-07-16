-- WezTerm config, ported from ghostty/config.ghostty.
-- Cross-platform: shared look everywhere; macOS chords/blur gated to darwin;
-- WSL domain wiring gated to Windows (where WezTerm actually runs for WSL).
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local is_darwin = wezterm.target_triple:find 'darwin' ~= nil
local is_windows = wezterm.target_triple:find 'windows' ~= nil

-- Shared appearance / typography (all platforms).
config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 12
config.color_scheme = 'rose-pine-moon'
config.default_cursor_style = 'SteadyBlock'   -- steady (non-blinking) block
config.enable_scroll_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'          -- resize handles only, no titlebar

if is_darwin then
  -- Make Cmd+<letter> emit Ctrl+<letter> so macOS chords reach the shell/tmux
  -- as control codes (e.g. Cmd+B -> Ctrl+B tmux prefix). Mirrors Ghostty's
  -- `keybind = cmd+<letter>=text:\xNN`. t and v are intentionally left to their
  -- defaults (new tab / paste), matching the Ghostty config's omissions.
  config.keys = {}
  for letter in ('abcdefghijklmnopqrsuwxyz'):gmatch '.' do
    table.insert(config.keys, {
      key = letter,
      mods = 'CMD',
      action = act.SendKey { key = letter, mods = 'CTRL' },
    })
  end

  -- Treat Option as Alt/Meta instead of composing accented characters.
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = false

  -- Translucent, blurred background (macOS-only knobs).
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
end

if is_windows then
  -- WezTerm runs on Windows for WSL, not inside the distro. Auto-discover every
  -- installed distro as a domain and default to the first, so opening WezTerm
  -- drops straight into the WSL shell (z4h/zsh) instead of PowerShell. Force the
  -- Linux home dir (not the Windows-mapped cwd) so new tabs open at $HOME.
  config.wsl_domains = wezterm.default_wsl_domains()
  for _, dom in ipairs(config.wsl_domains) do
    dom.default_cwd = '/home/ricky'
  end
  if #config.wsl_domains > 0 then
    config.default_domain = config.wsl_domains[1].name
  end

  -- Windows equivalent of the macOS translucency/blur above.
  config.window_background_opacity = 0.9
  config.win32_system_backdrop = 'Acrylic'
end

-- copy-on-select is off, which is already WezTerm's macOS default (no primary
-- selection auto-copy).
--
-- No direct WezTerm equivalent for these Ghostty settings, so they are dropped:
--   font-thicken / font-thicken-strength (macOS glyph thickening)
--   adjust-cell-height = 1 (1px cell padding; line_height here is a multiplier)
--   shell-integration-features = no-cursor
--   macos-icon = retro (app icon is not configurable from wezterm.lua)

return config

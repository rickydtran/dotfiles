-- Windows loader stub for WezTerm + WSL.
--
-- WezTerm runs as a Windows GUI app, so it reads its config from the Windows
-- profile, NOT from inside the distro. Home Manager can't reach the Windows
-- filesystem, so this one file is placed by hand to redirect Windows WezTerm at
-- the repo's single source of truth living inside WSL.
--
-- We do NOT dofile() the \\wsl.localhost\... share: Lua's C-runtime file I/O
-- rejects UNC paths with EINVAL. Instead we read the repo file by shelling into
-- WSL and evaluate it. target_triple is still "windows", so the target file's
-- `is_windows` branch runs (WSL domain + acrylic).
--
-- Install: copy this to  %USERPROFILE%\.config\wezterm\wezterm.lua  on Windows,
-- then edit the distro ("Debian") and path below to match yours.
local wezterm = require 'wezterm'

local ok, stdout, stderr = wezterm.run_child_process {
  'wsl.exe', '-d', 'Debian', '--',
  'cat', '/home/ricky/.dotfiles/wezterm/wezterm.lua',
}

if not ok then
  wezterm.log_error('failed to read wezterm.lua from WSL: ' .. (stderr or '?'))
  return wezterm.config_builder()
end

return assert(load(stdout, '@wsl:wezterm.lua'))()

# Ricky's dotfiles

A declarative macOS and Linux setup built on Nix.

The Mac is provisioned with [nix-darwin](https://github.com/LnL7/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and declarative [Homebrew](https://brew.sh/).
Linux dev boxes share the same user-level config through standalone Home Manager.
Dotfiles are symlinked into place by Home Manager (no stow on the Mac); [zsh4humans](https://github.com/romkatv/zsh4humans) still owns the shell.

## Bootstrap a new machine

Clone the repo and run the bootstrap.
It detects the OS, login, and hostname, registers the machine, installs Nix, and applies the config:

```bash
git clone https://github.com/rickydtran/dotfiles ~/.dotfiles
bash ~/.dotfiles/bootstrap.sh
```

There is no per-machine config to edit by hand.
`bootstrap.sh` writes `hosts/<hostname>.nix` from the detected environment, then hands off:

| OS | Handler | What it does |
|----|---------|--------------|
| macOS | `setup/mac.sh` | install Determinate Nix + Homebrew, then `darwin-rebuild switch` |
| Linux | `setup/linux.sh` | install Determinate Nix, then `home-manager switch` |

The right config is selected automatically by hostname (machines are keyed by hostname, not login, so the same login on two boxes doesn't collide).

### WSL (Windows)

WSL is just Linux, so it takes the `setup/linux.sh` path.
Do the WSL-specific prep first, then bootstrap as above.

1. Install a distro from Windows: `wsl --install -d Ubuntu`.
2. Enable systemd (the Nix daemon needs it) - inside the distro, put this in `/etc/wsl.conf`:

   ```ini
   [boot]
   systemd=true
   ```

3. Restart the distro from Windows: `wsl --shutdown`, then reopen it.
4. `sudo apt install -y git curl`, then run the clone + `bootstrap.sh` from above.
5. Open a fresh shell so Nix is on `PATH` (`exec zsh -l`).

WezTerm is a *Windows* app, so it does not read the config Home Manager links inside the distro.
Install it on Windows (`winget install wez.wezterm`), install `Hack Nerd Font` on Windows too, then create `%USERPROFILE%\.config\wezterm\wezterm.lua` from [`wezterm/windows-loader.lua`](wezterm/windows-loader.lua) (edit the distro name + login).
That stub redirects Windows WezTerm at the repo's `wezterm/wezterm.lua`, whose `is_windows` branch selects the WSL domain and drops you into the distro shell.

## How it works

Three layers, split by what changes and where:

| Layer | File | Scope | Owns |
|-------|------|-------|------|
| Machine | `nix/host.nix` | macOS only | Homebrew brews/casks, App Store apps (`mas`), macOS system defaults |
| User | `nix/user.nix` | macOS + Linux | CLI packages, fonts, and dotfile symlinks |
| Machines | `hosts/<hostname>.nix` | per machine | `{ type, system, username }`, auto-discovered by the flake |

`flake.nix` reads `hosts/` and builds one `darwinConfigurations` or `homeConfigurations` entry per file, keyed by hostname.
Adding a machine just means running `bootstrap.sh`; it writes the host file, so `flake.nix` itself is never edited per machine.

The actual config files (`zsh/`, `vim/`, `tmux/`, `git/`, ...) live in the repo and are symlinked live, so editing them takes effect immediately with no rebuild.

## Daily use

Apply changes after editing `nix/*`:

```bash
rebuild                                                          # macOS (alias for darwin-rebuild switch)
home-manager switch --flake ~/.dotfiles#$(hostname -s | tr A-Z a-z)   # Linux
```

| To change | Edit |
|-----------|------|
| a CLI tool (all machines) | `nix/user.nix` -> `home.packages` |
| a GUI app, App Store app, or macOS default | `nix/host.nix` |
| a shell / editor / tmux config | edit the dotfile directly (live symlink, no rebuild) |

`onActivation.cleanup = "uninstall"` means anything not declared is removed on the next rebuild, so declare what you want to keep.

## Layout

```
flake.nix          entry point; discovers hosts/, wires nix-darwin + Home Manager
hosts/<host>.nix   one per machine (type, system, username), written by bootstrap
setup/lib.sh       shared bootstrap helpers (hostkey derivation)
nix/host.nix       macOS machine layer
nix/user.nix       shared user layer (packages, fonts, dotfile links)
setup/mac.sh       macOS bootstrap
setup/linux.sh     Linux bootstrap
bootstrap.sh       OS router; self-registers the machine
zsh/ vim/ tmux/ git/ ssh/ htop/   the dotfiles themselves
```

## Testing

CI (`.github/workflows/ci.yml`) builds both configs on every push:

- the darwin system closure on a macOS runner
- the shared Home Manager config on a Linux runner

Locally, `docker_test.sh` runs an end-to-end test in a container: it builds the Linux config, activates it, and asserts the dotfile links and tools resolve.
A real macOS box is its own proof; there is no macOS container (macOS cannot run in Docker).

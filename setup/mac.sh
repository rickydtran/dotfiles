#!/usr/bin/env bash
# Bootstrap the Mac's Nix layer: install Determinate Nix, then apply the flake
# (nix-darwin + Home Manager). Safe to re-run. The shell/editor/tmux configs are
# linked by Home Manager (see nix/user.nix) - no stow needed on the Mac.
set -euo pipefail

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && cd .. && pwd )

# 1. Install Determinate Nix if missing. The install.determinate.sh helper host is
#    DNS-blocked on some networks, so fetch the installer binary straight from GitHub
#    releases (github.com resolves) instead. --no-confirm skips the interactive prompt.
if ! command -v nix &>/dev/null; then
  echo "==> Installing Determinate Nix"
  case "$(uname -m)" in
    arm64|aarch64) triple=aarch64-darwin ;;
    x86_64)        triple=x86_64-darwin ;;
    *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
  esac
  installer="$(mktemp)"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    "https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-${triple}" \
    -o "$installer"
  chmod +x "$installer"
  "$installer" install --no-confirm
  rm -f "$installer"
fi

# 2. The installer does NOT put nix on the CURRENT shell's PATH. Source the daemon
#    profile so the rest of this script can use nix in the same run.
if ! command -v nix &>/dev/null; then
  daemon=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  [ -e "$daemon" ] && . "$daemon"
fi
if ! command -v nix &>/dev/null; then
  echo "nix still not on PATH. Open a NEW terminal and re-run this script." >&2
  exit 1
fi
NIX="$(command -v nix)"

# 3. Homebrew (already installed on this machine; kept for a fresh box).
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 4. Apply the flake. The config is keyed by login, so select it with whoami.
#    sudo resets PATH (secure_path), so invoke nix by full path.
user="$(whoami)"
echo "==> Applying nix-darwin flake #$user (sudo)"
if [ -x /run/current-system/sw/bin/darwin-rebuild ]; then
  sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "$DOTFILES_DIR#$user"
else
  # First run only: darwin-rebuild doesn't exist yet, bootstrap it from the flake input.
  sudo "$NIX" run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake "$DOTFILES_DIR#$user"
fi

echo "==> Done. Open a new terminal, then iterate with:  rebuild"

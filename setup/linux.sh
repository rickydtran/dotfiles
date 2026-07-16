#!/usr/bin/env bash
# Bootstrap a Linux dev box: install Determinate Nix, then apply Home Manager
# (the same nix/user.nix the Mac uses). No stow - HM owns the dotfile links.
# Verified on WSL (Ubuntu, x86_64) as well as the Mac path (setup/mac.sh).
set -euo pipefail

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && cd .. && pwd )
# shellcheck source=setup/lib.sh
. "$DOTFILES_DIR/setup/lib.sh"

# 1. Install Determinate Nix if missing (GitHub release; install.determinate.sh may be DNS-blocked).
if ! command -v nix &>/dev/null; then
  echo "==> Installing Determinate Nix"
  case "$(uname -m)" in
    x86_64)        triple=x86_64-linux ;;
    aarch64|arm64) triple=aarch64-linux ;;
    *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
  esac
  installer="$(mktemp)"
  curl --proto '=https' --tlsv1.2 -sSf -L \
    "https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-${triple}" \
    -o "$installer"
  chmod +x "$installer"
  "$installer" install --no-confirm
fi

# 2. Make nix usable in this shell (installer doesn't update the current PATH).
if ! command -v nix &>/dev/null; then
  daemon=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  [ -e "$daemon" ] && . "$daemon"
fi
command -v nix >/dev/null || { echo "nix not on PATH - open a new shell and re-run." >&2; exit 1; }

# 3. Apply Home Manager. The config is keyed by hostname, so select it with hostkey.
#    -b backup handles pre-existing dotfiles.
key="$(hostkey)"
echo "==> Applying Home Manager #$key"
nix run home-manager/master -- switch -b backup --flake "$DOTFILES_DIR#$key"

echo "==> Done. Open a new shell, then iterate with: home-manager switch --flake ~/.dotfiles#$key"

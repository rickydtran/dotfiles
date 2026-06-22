#!/usr/bin/env bash
# Bootstrap a Linux dev box: install Determinate Nix, then apply Home Manager
# (the same nix/user.nix the Mac uses). No stow — HM owns the dotfile links.
# NOTE: not yet tested on a real Linux box; the Mac path (setup/mac.sh) is verified.
set -euo pipefail

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && cd .. && pwd )

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
command -v nix >/dev/null || { echo "nix not on PATH — open a new shell and re-run." >&2; exit 1; }

# 3. Apply Home Manager. The config is keyed by login, so select it with whoami.
#    -b backup handles pre-existing dotfiles.
user="$(whoami)"
echo "==> Applying Home Manager #$user"
nix run home-manager/master -- switch -b backup --flake "$DOTFILES_DIR#$user"

echo "==> Done. Open a new shell, then iterate with: home-manager switch --flake ~/.dotfiles#$user"

#!/usr/bin/env bash
# One-shot entry point. Clones the repo, then hands off to the per-OS Nix bootstrap.
#   macOS → setup/mac.sh   (nix-darwin + Home Manager + Homebrew)
#   Linux → setup/linux.sh (Home Manager standalone)
# No stow — Home Manager owns the dotfile links on every machine.
set -euo pipefail

DOTFILES_REPO="https://github.com/rickydtran/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "==> Cloning dotfiles to $DOTFILES_DIR"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

case "$(uname -s)" in
  Darwin) exec bash "$DOTFILES_DIR/setup/mac.sh" ;;
  Linux)  exec bash "$DOTFILES_DIR/setup/linux.sh" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

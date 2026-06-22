#!/usr/bin/env bash
# One-shot entry point. Clones the repo, auto-registers THIS machine as
# hosts/<login>.nix (detected from the environment), then hands off to the
# per-OS Nix bootstrap. No per-machine flake.nix editing — ever.
#
# The impurity lives HERE, in the shell (detect env, write a file). The flake
# then reads that file purely. Best of both: zero manual edits + pure eval.
set -euo pipefail

DOTFILES_REPO="https://github.com/rickydtran/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "==> Cloning dotfiles to $DOTFILES_DIR"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Detect platform → nix `type` + `system`.
case "$(uname -s)" in
  Darwin) type=darwin ; os=darwin ;;
  Linux)  type=home   ; os=linux  ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  arm64|aarch64) arch=aarch64 ;;
  x86_64)        arch=x86_64  ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

# Register this machine (idempotent). Flakes only see git-tracked/staged files,
# so stage it — otherwise the freshly-written host is invisible to nix eval.
host="$DOTFILES_DIR/hosts/$(whoami).nix"
if [ ! -f "$host" ]; then
  echo "==> Registering this machine -> hosts/$(whoami).nix"
  mkdir -p "$DOTFILES_DIR/hosts"
  printf '{ type = "%s"; system = "%s-%s"; username = "%s"; }\n' \
    "$type" "$arch" "$os" "$(whoami)" > "$host"
  git -C "$DOTFILES_DIR" add "$host" 2>/dev/null || true
fi

case "$type" in
  darwin) exec bash "$DOTFILES_DIR/setup/mac.sh" ;;
  home)   exec bash "$DOTFILES_DIR/setup/linux.sh" ;;
esac

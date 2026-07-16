#!/usr/bin/env bash
# Shared helpers for bootstrap.sh + setup/{mac,linux}.sh.

# hostkey: a stable, lowercase, nix/filename-safe identifier for THIS machine.
# Machines are keyed by HOSTNAME, not login, so boxes that share a login - e.g.
# `ricky` on both a Mac and a WSL box - get distinct hosts/<key>.nix entries and
# don't clobber each other. The `username` inside the host file still carries the
# login; only the machine key comes from here.
hostkey() {
  local h
  if [ "$(uname -s)" = Darwin ]; then
    # LocalHostName is the stable Bonjour name (no spaces, survives network changes).
    h=$(scutil --get LocalHostName 2>/dev/null) || h=$(hostname -s)
  else
    h=$(hostname -s 2>/dev/null) || h=$(cat /etc/hostname 2>/dev/null)
  fi
  printf '%s' "$h" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed -e 's/^-*//' -e 's/-*$//'
}

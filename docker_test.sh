#!/usr/bin/env bash
# End-to-end test of the Linux Home Manager path in a container. The build is the
# test: it builds homeConfigurations.<tester>.activationPackage for the container
# arch, activates it, and asserts the dotfile links + tools (gls, nvim) resolve.
set -euo pipefail
cd "$(dirname "$0")"
docker build -t dotfiles-linux-test .
echo "Linux home-manager config builds and activates cleanly."

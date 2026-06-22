#!/usr/bin/env bash
# Validate the Linux Home Manager path in a container. The build is the test:
# it builds homeConfigurations.<tester>.activationPackage for the container arch.
set -euo pipefail
cd "$(dirname "$0")"
docker build -t dotfiles-linux-test .
echo "Linux home-manager config builds cleanly."

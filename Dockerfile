# Validates the Linux Home Manager path of this flake, in a container.
# The build IS the test: if `nix build` of the activation package succeeds,
# the shared nix/user.nix builds on Linux.
#   docker build -t dotfiles-linux-test .
FROM nixos/nix:latest

RUN mkdir -p /etc/nix && \
    printf 'experimental-features = nix-command flakes\n' >> /etc/nix/nix.conf

COPY . /dotfiles
WORKDIR /dotfiles

# Drop git so the throwaway host file is visible to the flake (plain-dir flake,
# no git staging needed), register a Linux host matching the container arch,
# then build its Home Manager activation package.
RUN rm -rf .git result && \
    printf '{ type = "home"; system = "aarch64-linux"; username = "tester"; }\n' > hosts/tester.nix && \
    nix build '.#homeConfigurations.tester.activationPackage' --print-build-logs && \
    echo "=== LINUX HOME-MANAGER BUILD OK ==="

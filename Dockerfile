# End-to-end validation of the Linux Home Manager path, in a container.
# The build IS the test: it builds homeConfigurations.<tester>.activationPackage
# for the container arch, ACTIVATES it, and verifies the dotfile links + a tool.
#   docker build -t dotfiles-linux-test .
FROM nixos/nix:latest

RUN mkdir -p /etc/nix && \
    printf 'experimental-features = nix-command flakes\n' >> /etc/nix/nix.conf

COPY . /dotfiles
WORKDIR /dotfiles

# Register a Linux host matching the container arch, build it, then activate as
# "tester" (root runs it, with tester's USER/HOME env + a pre-created profile dir,
# which avoids non-root nix-store-write issues). Verify the links and a tool.
RUN rm -rf .git result && \
    printf '{ type = "home"; system = "aarch64-linux"; username = "tester"; }\n' > hosts/tester.nix && \
    nix build '.#homeConfigurations.tester.activationPackage' && \
    mkdir -p /home/tester/.local/state/nix/profiles && \
    USER=tester HOME=/home/tester ./result/activate && \
    echo "=== verify dotfile links ===" && \
    ls -la /home/tester/.zshrc /home/tester/.tmux.conf /home/tester/.gitconfig && \
    echo "=== verify tools resolve through the activated HM profile ===" && \
    test -x /home/tester/.nix-profile/bin/gls && \
    test -x /home/tester/.nix-profile/bin/nvim && \
    /home/tester/.nix-profile/bin/gls --version | head -1 && \
    echo "=== E2E ACTIVATION OK ==="

{ config, pkgs, ... }:

# USER LAYER (Home Manager): reproducible CLI baseline + fonts + config symlinks.
#
# DELIBERATE DESIGN CHOICE:
#   - NO programs.zsh → z4h owns the shell. We symlink the raw .zshrc instead of
#                       letting HM generate one, so z4h stays 100% in charge.
#   - NO programs.git → your rich .gitconfig has the real aliases; symlink, don't regenerate.
#
# home.file below replaces `stow` ON THE MAC ONLY. It points mkOutOfStoreSymlink at the
# SAME files stow uses (the package dirs), so the repo layout is unchanged and remote
# Linux boxes can still `stow zsh` from the identical source. One source of truth.
let
  dot = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dot}/${path}";
in
{
  home.username = "ricky";
  home.homeDirectory = "/Users/ricky";
  home.stateVersion = "23.11";
  home.language.base = "en_US.UTF-8";

  # Seeded from your actual `brew leaves`. Pure-CLI tools move here; brew keeps GUI/mac-native.
  home.packages = with pkgs; [
    # shell + core (coreutils gives gls, which your ls aliases depend on)
    coreutils
    bash
    zsh
    stow
    tmux
    htop
    neovim
    tree
    watch
    dos2unix

    # search / data
    jq
    fd
    ripgrep
    poppler

    # git tooling (binaries only — config is symlinked via home.file below)
    git
    gh
    git-filter-repo
    lazygit

    # net / sys
    curl
    wget
    nmap
    nats-server

    # build toolchain
    cmake
    automake
    autoconf
    libtool
    pkg-config        # nixpkgs attr for pkgconf
    protobuf

    # language runtimes / toolchains
    go
    bun
    uv
    rustup
    golangci-lint

    # cloud / infra
    azure-cli
    oci-cli
    kubernetes-helm   # nixpkgs attr for helm
    kind

    # misc
    just
    fastfetch
    zip
    unzip

    # fonts (Ghostty/terminal want Hack Nerd Font)
    nerd-fonts.hack
    noto-fonts
    noto-fonts-color-emoji

    # ── intentionally NOT here (kept on brew/own installer) ───────────────
    # gemini-cli  → in nixpkgs but lags; fast-moving JS tooling → brew (host.nix)
    # ccusage     → not in nixpkgs (npm tool) → brew (host.nix)
    # lmstudio (lms) → not in nixpkgs; keeps its own installer (~/.lmstudio)
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Config symlinks — what `stow` did, now owned by `darwin-rebuild` on the Mac.
  # Each points at the existing stow package dir, so files stay live-editable in the repo.
  home.file = {
    ".zshrc".source     = link "zsh/.zshrc";
    ".zshenv".source    = link "zsh/.zshenv";
    ".p10k.zsh".source  = link "zsh/.p10k.zsh";
    ".env.zsh".source   = link "zsh/.env.zsh";
    ".vimrc".source     = link "vim/.vimrc";
    ".tmux.conf".source = link "tmux/.tmux.conf";
    ".gitconfig".source     = link "git/.gitconfig";
    ".gitconfig.inc".source = link "git/.gitconfig.inc";
    ".ssh/config".source    = link "ssh/.ssh/config";
    ".config/htop/htoprc".source = link "htop/.config/htop/htoprc";
  };
}

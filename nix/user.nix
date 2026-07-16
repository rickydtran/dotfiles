{ config, pkgs, lib, username, inputs, ... }:

# USER LAYER (Home Manager): reproducible CLI baseline + fonts + config symlinks.
#
# DELIBERATE DESIGN CHOICE:
#   - NO programs.zsh -> z4h owns the shell. We symlink the raw .zshrc instead of
#                       letting HM generate one, so z4h stays 100% in charge.
#   - NO programs.git -> your rich .gitconfig has the real aliases; symlink, don't regenerate.
#
# home.file below links every dotfile from the repo into $HOME - on BOTH Mac (via
# nix-darwin's HM) and Linux dev boxes (via standalone HM). Replaces stow entirely;
# mkOutOfStoreSymlink keeps the files live-editable in the repo. One source of truth.
let
  dot = "${config.home.homeDirectory}/.dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dot}/${path}";
in
{
  # Username comes from the flake per machine (specialArgs); flake eval is pure (no $USER).
  home.username = username;
  # Path derives from username; only the macOS (/Users) vs Linux (/home) prefix differs.
  home.homeDirectory = (if pkgs.stdenv.isDarwin then "/Users/" else "/home/") + username;
  home.stateVersion = "23.11";
  home.language.base = "en_US.UTF-8";

  # Seeded from your actual `brew leaves`. Pure-CLI tools move here; brew keeps GUI/mac-native.
  home.packages = with pkgs; [
    # shell + core. coreutils-PREFIXED gives `gls`/`gcat`/... (the `g` prefix the
    # darwin ls/ll aliases in .zshrc rely on - same convention as brew coreutils).
    coreutils-prefixed
    bash
    zsh
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

    # git tooling (binaries only - config is symlinked via home.file below)
    git
    gh
    git-filter-repo
    lazygit
    delta             # syntax-highlighting diff pager (used by dsf())
    inputs.treehouse.packages.${pkgs.system}.default   # git-worktree manager (not in nixpkgs)

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
    buf               # protobuf tooling (was bufbuild/buf tap)

    # language runtimes / toolchains
    go
    bun
    uv
    rustup
    golangci-lint
    cargo-deny        # rust dependency/license linter
    shellcheck        # shell script linter

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

    # -- intentionally NOT here (kept on brew/own installer) ---------------
    # gemini-cli  -> in nixpkgs but lags; fast-moving JS tooling -> brew (host.nix)
    # ccusage     -> not in nixpkgs (npm tool) -> brew (host.nix)
    # lmstudio (lms) -> not in nixpkgs; keeps its own installer (~/.lmstudio)
  ]
  # Platform-specific CLI tools (most Mac-specific stuff is GUI -> host.nix instead).
  ++ lib.optionals pkgs.stdenv.isLinux [
    macchanger        # MAC-address changer - Linux-only in nixpkgs (was acrogenesis tap on Mac)
    # strace  iproute2  ...
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # mac-only CLI (rare)
  ];

  fonts.fontconfig.enable = true;

  # Install the `home-manager` CLI so the documented iterate command works
  # (the Linux bootstrap otherwise only reaches HM via `nix run`).
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Config symlinks - Home Manager owns these on every machine (Mac + Linux).
  # Each points at the repo's package dir, so files stay live-editable.
  home.file = {
    ".zshrc".source     = link "zsh/.zshrc";
    ".zshenv".source    = link "zsh/.zshenv";
    ".p10k.zsh".source  = link "zsh/.p10k.zsh";
    ".env.zsh".source   = link "zsh/.env.zsh";
    ".vimrc".source     = link "vim/.vimrc";
    ".config/nvim/init.vim".source = link "vim/init.vim";
    ".tmux.conf".source = link "tmux/.tmux.conf";
    ".gitconfig".source     = link "git/.gitconfig";
    ".gitconfig.inc".source = link "git/.gitconfig.inc";
    ".ssh/config".source    = link "ssh/.ssh/config";
    ".config/htop/htoprc".source = link "htop/.config/htop/htoprc";
    ".config/wezterm/wezterm.lua".source = link "wezterm/wezterm.lua";
    ".zsh/completions/_brew".source = link "zsh/completions/_brew";  # brew tab-completion (see .zshrc fpath)
    # One agent-instructions source, symlinked into every AI agent's config path.
    ".claude/CLAUDE.md".source          = link "AGENTS.md";
    ".codex/AGENTS.md".source           = link "AGENTS.md";
    ".gemini/GEMINI.md".source          = link "AGENTS.md";
    ".config/opencode/AGENTS.md".source = link "AGENTS.md";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # Ghostty reads its config from macOS app-support (mac-only path).
    "Library/Application Support/com.mitchellh.ghostty/config".source =
      link "ghostty/config.ghostty";
  };
}

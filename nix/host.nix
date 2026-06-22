{ pkgs, username, ... }:

# MACHINE LAYER (nix-darwin): GUI apps, mac-native CLIs, and macOS system defaults.
# Ownership rule: Homebrew owns GUI + mac-native tools; Nix owns reproducible CLI.
# This file closes the two biggest gaps in the stow setup: what's installed + system prefs.
{
  # Determinate Nix Installer manages Nix itself.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    # "uninstall" prunes any brew package/cask not declared here on each rebuild.
    # ("zap" would also wipe their app data — too aggressive.)
    onActivation.cleanup = "uninstall";
    taps = [ ];

    # Mac-native / awkward-in-nix tooling — kept on brew deliberately.
    brews = [
      "colima"                        # mac VM for containers
      "docker"
      "docker-buildx"
      "docker-compose"
      "lima-additional-guestagents"
      "iproute2mac"                   # mac shim for ip(8)
      "mingw-w64"                     # windows cross-toolchain
      "mas"                           # App Store CLI — drives masApps below
      # Fast-moving JS CLI — kept on brew (nixpkgs lags Google's near-daily releases).
      # Per the "right ecosystem manager" rule, not nix.
      "gemini-cli"
      # (buf + macchanger moved to nix/user.nix — no more third-party taps)
    ];

    # GUI apps via cask. "Working core" filter: tools that define how you
    # work, not entertainment. Commented lines = opt-in (uncomment to declare).
    casks = [
      # terminals / editors / dev
      "ghostty"
      "wezterm"
      "iterm2"
      "visual-studio-code"
      "sublime-text"
      "utm"
      # browsers
      "firefox"
      "google-chrome"
      # AI
      "chatgpt"
      "claude"
      # comms / work
      "slack"
      "zoom"
      "microsoft-teams"
      "microsoft-outlook"        # moved from App Store → cask (same app, more reproducible)
      "amazon-chime"
      "granola"
      "windows-app"              # MS Remote Desktop — moved from App Store → cask
      # notes / launcher / window mgmt
      "obsidian"
      "raycast"
      "rectangle"
      # cloud storage
      "google-drive"
      "onedrive"
      # network / security
      "mullvad-vpn"
      "wireshark-app"
      # "tailscale-app"   # MANUAL SWAP: App Store build is sandboxed; remove it first,
      #                   # then uncomment — the cask is the fuller standalone build
      # display / peripherals (ambient workflow)
      "betterdisplay"
      "mos"
      "scroll-reverser"
      "displaylink"
      "elgato-control-center"
      "logitune"
      "logi-options+"
      # docs
      "mactex"
      "skim"
      "thaw"
      # ── opt-in: borderline (personal/occasional) ──
      # "spotify"
      # "obs"
      # "tradingview"
      # "microsoft-edge"
      # "balenaetcher"
      # "adguard"
      # "microsoft-office"   # bundles Outlook → conflicts with App Store Outlook (masApps)
      # ── opt-in: entertainment (not "working core") ──
      # "steam"
      # "runelite"
    ];

    # App Store apps (App-Store-exclusive, or already installed from the Store).
    # Requires "mas" (above) + Apple ID sign-in on a fresh machine.
    masApps = {
      "Strongbox"       = 897283731;    # password manager (no cask)
      "RunCat"          = 1429033973;   # menu-bar CPU monitor (no cask)
      "CleanMyKeyboard" = 6468120888;
      "AdGuard for Safari"   = 1440147259;   # Safari extension (≠ standalone `adguard` cask)
      "Obsidian Web Clipper" = 6720708363;   # Safari extension
      "Tailscale"            = 1475387142;   # installed App Store build (cask swap optional later)
    };
  };

  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;   # login shell only — z4h still owns ALL zsh config (see user.nix note)
  };

  # macOS defaults — the layer stow can never reach. Tuned for fast key repeat + dev ergonomics.
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;            # key repeat over accent popup
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      AppleShowAllExtensions = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad.Clicking = true;
  };

  environment.systemPath = [
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/${username}/bin"
  ];

  system.stateVersion = 6;
}

{
  description = "Ricky's Mac baseline — nix-darwin + Home Manager (package & system layer only)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
  let
    # TURNKEY: one entry per machine below, keyed by its LOGIN. bootstrap.sh and the
    # `rebuild` alias auto-select with `#$(whoami)`, so a clean machine needs nothing
    # but its one-line entry. username flows into host.nix + user.nix via specialArgs.

    # Mac (full system + user layer).
    mkDarwin = { system, username }: nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit username; };                 # → host.nix
      modules = [
        ./nix/host.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit username; };   # → user.nix
          home-manager.users.${username} = import ./nix/user.nix;
        }
      ];
    };

    # Linux dev box (user layer only; macOS system defaults don't apply).
    mkHome = { system, username }: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit username; };            # → user.nix
      modules = [ ./nix/user.nix ];
    };
  in {
    # Apply on a Mac:  darwin-rebuild switch --flake ~/.dotfiles#$(whoami)
    darwinConfigurations = {
      ricky = mkDarwin { system = "aarch64-darwin"; username = "ricky"; };
      # new Mac → add one line keyed by its login, e.g.:
      # rickyt = mkDarwin { system = "aarch64-darwin"; username = "rickyt"; };
    };

    # Apply on a Linux box:  home-manager switch --flake ~/.dotfiles#$(whoami)
    homeConfigurations = {
      # new Linux box → add one line keyed by its login, e.g.:
      # rickytran = mkHome { system = "x86_64-linux"; username = "rickytran"; };
    };
  };
}

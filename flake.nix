{
  description = "Ricky's Mac baseline - nix-darwin + Home Manager (package & system layer only)";

  inputs = {
    # Pinned to the 26.05 stable release (was nixpkgs-unstable) for fewer surprise
    # breakages on rebuild. nixos-26.05 is cross-platform (mac + linux).
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manages Homebrew itself declaratively (the brew install + taps), not just its packages.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    treehouse = {
      url = "github:kunchenguid/treehouse";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, nix-homebrew, ... }:
  let
    inherit (nixpkgs) lib;

    # Mac (full system + user layer).
    mkDarwin = { system, username, ... }: nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit username; };                 # -> host.nix
      modules = [
        ./nix/host.nix
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit username inputs; };   # -> user.nix
          home-manager.users.${username} = import ./nix/user.nix;
        }
      ];
    };

    # Linux dev box (user layer only; macOS system defaults don't apply).
    mkHome = { system, username, ... }: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit username inputs; };            # -> user.nix
      modules = [ ./nix/user.nix ];
    };

    # TURNKEY: machines are auto-discovered from ./hosts/<hostkey>.nix - bootstrap.sh
    # writes that file from the environment on a fresh box (keyed by hostname, so a
    # shared login on two boxes doesn't collide), so flake.nix is NEVER edited per
    # machine. Each host file is just data:
    #   { type = "darwin"|"home"; system = "<nix system>"; username = "<login>"; }
    hosts = lib.mapAttrs'
      (file: _: lib.nameValuePair
        (lib.removeSuffix ".nix" file)
        (import (./hosts + "/${file}")))
      (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n)
        (builtins.readDir ./hosts));
    ofType = t: lib.filterAttrs (_: cfg: cfg.type == t) hosts;
  in {
    # Apply on a Mac:       darwin-rebuild switch --flake ~/.dotfiles#<hostname>
    darwinConfigurations = lib.mapAttrs (_: mkDarwin) (ofType "darwin");
    # Apply on a Linux box: home-manager switch --flake ~/.dotfiles#<hostname>
    homeConfigurations   = lib.mapAttrs (_: mkHome)   (ofType "home");
  };
}

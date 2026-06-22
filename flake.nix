{
  description = "Ricky's Mac baseline - nix-darwin + Home Manager (package & system layer only)";

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
    inherit (nixpkgs) lib;

    # Mac (full system + user layer).
    mkDarwin = { system, username, ... }: nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit username; };                 # -> host.nix
      modules = [
        ./nix/host.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit username; };   # -> user.nix
          home-manager.users.${username} = import ./nix/user.nix;
        }
      ];
    };

    # Linux dev box (user layer only; macOS system defaults don't apply).
    mkHome = { system, username, ... }: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit username; };            # -> user.nix
      modules = [ ./nix/user.nix ];
    };

    # TURNKEY: machines are auto-discovered from ./hosts/<login>.nix - bootstrap.sh
    # writes that file from the environment on a fresh box, so flake.nix is NEVER
    # edited per machine. Each host file is just data:
    #   { type = "darwin"|"home"; system = "<nix system>"; username = "<login>"; }
    hosts = lib.mapAttrs'
      (file: _: lib.nameValuePair
        (lib.removeSuffix ".nix" file)
        (import (./hosts + "/${file}")))
      (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n)
        (builtins.readDir ./hosts));
    ofType = t: lib.filterAttrs (_: cfg: cfg.type == t) hosts;
  in {
    # Apply on a Mac:       darwin-rebuild switch --flake ~/.dotfiles#$(whoami)
    darwinConfigurations = lib.mapAttrs (_: mkDarwin) (ofType "darwin");
    # Apply on a Linux box: home-manager switch --flake ~/.dotfiles#$(whoami)
    homeConfigurations   = lib.mapAttrs (_: mkHome)   (ofType "home");
  };
}

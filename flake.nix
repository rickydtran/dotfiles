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
    # Standalone Home Manager for Linux dev boxes — same user.nix as the Mac.
    #   home-manager switch --flake ~/.dotfiles#ricky        (x86_64)
    #   home-manager switch --flake ~/.dotfiles#ricky-arm    (aarch64)
    mkHome = system: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./nix/user.nix ];
    };
  in {
    # Mac: full system + user layer.  darwin-rebuild switch --flake ~/.dotfiles#mac
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./nix/host.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.ricky = import ./nix/user.nix;
        }
      ];
    };

    # Linux: user layer only (no nix-darwin; macOS system defaults don't apply).
    homeConfigurations = {
      "ricky"     = mkHome "x86_64-linux";
      "ricky-arm" = mkHome "aarch64-linux";
    };
  };
}

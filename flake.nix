{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#momcorp
      darwinConfigurations."momcorp" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import inputs.nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          overlays = [
            inputs.nix-vscode-extensions.overlays.default
          ];
        };
        modules = [
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.jaym = import ./modules/home-manager;
            };
          }
        ];
      };
    };
}

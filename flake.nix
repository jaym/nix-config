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

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      darwin,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let 
      buildDarwin = system: darwin.lib.darwinSystem {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.nix-vscode-extensions.overlays.default
            inputs.mcp-servers-nix.overlays.default
            (final: prev: {
              mcp-nixos = inputs.mcp-nixos.packages."${final.system}".default;
            })
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
      buildHomeManager = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.nix-vscode-extensions.overlays.default
            inputs.mcp-servers-nix.overlays.default
            (final: prev: {
              mcp-nixos = inputs.mcp-nixos.packages."${final.system}".default;
            })
          ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./modules/home-manager
        ];
      };
      buildAarch64Darwin = buildDarwin "aarch64-darwin";
      buildX86_64Linux = buildHomeManager "x86_64-linux";
      darwinHosts = ["momcorp" "flexo"];
      linuxHosts = ["robotarms"];
    in 
    {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinHosts (hostName: buildAarch64Darwin);
      homeConfigurations = {
        "jaym@robotarms" = buildX86_64Linux;
      };
    };
}

{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
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
      eachSystem = inputs.nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      # Common pkgs configuration
      mkPkgs =
        system:
        import nixpkgs {
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

      treefmtEval = eachSystem (
        system:
        inputs.treefmt-nix.lib.evalModule (mkPkgs system) {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            nixfmt.package = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
          };
        }
      );

      buildDarwin =
        system:
        darwin.lib.darwinSystem {
          inherit system;
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit inputs; };
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
      buildHomeManager =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./modules/home-manager
          ];
        };
      buildAarch64Darwin = buildDarwin "aarch64-darwin";
      buildX86_64Linux = buildHomeManager "x86_64-linux";
      darwinHosts = [
        "momcorp"
        "flexo"
      ];
      linuxHosts = [ "robotarms" ];
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinHosts (hostName: buildAarch64Darwin);
      homeConfigurations = {
        "jaym@robotarms" = buildX86_64Linux;
      };

      # treefmt
      formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);
      checks = eachSystem (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
    };
}

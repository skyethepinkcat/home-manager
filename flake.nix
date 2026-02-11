{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    # nixvim-config = {
    #   url = "git+ssh://git@github.com/skyethepinkcat/nixvim?ref=nvix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    home-manager,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        mkHomeConfig = username:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
            ];
            extraSpecialArgs = {
              inherit system username inputs;
            };
          };
      in {
        # formatter.${system}
        formatter = pkgs.alejandra;

        # devShells.${system}.default
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nil
            pkgs.alejandra
          ];
        };

        legacyPackages.homeConfigurations = {
          ii69854 = mkHomeConfig "ii69854";
          skye = mkHomeConfig "skye";
        };
      };
    };
}

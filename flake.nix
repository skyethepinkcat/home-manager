{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # adding the starter input here
    nvchad-config = {
      url = "git+ssh://git@github.com/skyethepinkcat/nvim";
      flake = false;
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-config"; # <- overwrite the module input here
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "git+ssh://git@github.com/skyethepinkcat/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          mkHomeConfig =
            username:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./home.nix
              ];
              extraSpecialArgs = {
                inherit system username inputs;
              };
            };
        in
        {
          # formatter.${system}
          formatter = pkgs.nixfmt;

          # devShells.${system}.default
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nil
              pkgs.nixfmt
              pkgs.shfmt
              pkgs.age
              pkgs.sops
            ];
          };

          legacyPackages.homeConfigurations = {
            ii69854 = mkHomeConfig "ii69854";
            skye = mkHomeConfig "skye";
          };
        };
    };
}

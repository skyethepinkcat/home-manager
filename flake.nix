{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-edge.url = "github:NixOS/nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:skyethepinkcat/nixvim/release-26.05";
      inputs = {
        skyepkgs.follows = "skyepkgs";
        nixpkgs.follows = "nixpkgs";
      };
    };

    claude-prompt = {
      url = "github:skyethepinkcat/claude-prompt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    skyepkgs = {
      url = "github:skyethepinkcat/skyepkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" "https://skyethepinkcat.cachix.org"];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="  "skyethepinkcat.cachix.org-1:N9c9/ovsKf24kIgQpGvU6+wjYyGNjPPESgM6gP7weKk="];
  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      debug = true;

      perSystem =
        {
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
                inputs.sops-nix.homeManagerModules.sops
                inputs.skyepkgs.homeManagerModules.opencode-monitor
              ];
              extraSpecialArgs = {
                inherit system username inputs;
              };
            };
        in
        {
          # devShells.${system}.default
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              just
              shfmt
              age
              sops
              treefmt
              cachix
              (ruby.withPackages (
                ps: with ps; [
                  rubocop
                  rainbow
                  minitest
                ]
              ))
            ];
          };

          legacyPackages.homeConfigurations = {
            ii69854 = mkHomeConfig "ii69854";
            skye = mkHomeConfig "skye";
          };
        };
    };
}

{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-edge.url = "github:NixOS/nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:skyethepinkcat/nixvim";
      inputs = {
        skyepkgs.follows = "skyepkgs";
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
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
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

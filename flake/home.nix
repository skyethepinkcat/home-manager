{
  config,
  inputs,
  lib,
  ...

}:
let

  inherit (inputs) home-manager nixpkgs;
  hosts = import inputs.nix-hosts {
    local_domain = "taila9d2a7.ts.net";
    inherit lib;
  };

in
{
  flake.homeConfigurations = lib.concatMapAttrs (name: host: {
    "${host.primaryUser}@${host.name}" = home-manager.lib.homeManagerConfiguration {
      modules = [
        ../home.nix
        inputs.sops-nix.homeManagerModules.sops
      ];
      pkgs = import nixpkgs {
        inherit (host) system;
        overlays = [
          inputs.skyepkgs.overlays.default

        ];
      };
      extraSpecialArgs = {
        username = host.primaryUser;
        inherit host inputs;
        nix-hosts = hosts;
      };
    };

  }) hosts.hosts;

}

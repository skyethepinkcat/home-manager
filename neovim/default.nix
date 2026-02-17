{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.neovim-config;
in
{
  imports = [
    inputs.nix4nvchad.homeManagerModule
    inputs.nixvim-config.homeModules.default
    ./options.nix
  ];
  config = lib.mkIf cfg.enable {
    programs = {
      nvchad = {
        enable = cfg.use-nvchad;
        hm-activation = true;
        backup = false;
        extraPackages =
          with pkgs;
          [
            nixfmt
            nil
          ]
          ++ cfg.packages;
      };
      nixvim = {
        enable = cfg.use-nixvim;
        extraPackages = cfg.packages;
      };

      neovide = {
        enable = true;
        settings = {
          fork = true;
        };
      };
    };
  };

}

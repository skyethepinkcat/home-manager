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
    inputs.nixvim-config.homeModules.default
    ./options.nix
  ];
  config = lib.mkIf cfg.enable {
    programs = {
      nixvim = {
        enable = true;
        ai.suggestion = false;
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

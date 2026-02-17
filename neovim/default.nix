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
  imports = [ inputs.nix4nvchad.homeManagerModule ];
  config = lib.mkIf cfg.enable {
    programs = {
      nvchad = {
        enable = true;
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
    };
  };
  options = {
    neovim-config = {
      enable = lib.mkEnableOption "Enable Module";
      packages = lib.mkOption {
        default = [ ];
        description = "Packages to include in the neovim environment";
      };
    };
  };
}

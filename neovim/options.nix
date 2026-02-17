{ lib, ... }:
{
  options = {
    neovim-config = {
      enable = lib.mkEnableOption "Enable Module";
      use-nvchad = lib.mkOption {
        default = true;
        description = "Use nvchad configuration.";
      };
      use-nixvim = lib.mkOption {
        default = false;
        description = "Use nixvim configuration instead of nvchad.";
      };
      packages = lib.mkOption {
        default = [ ];
        description = "Packages to include in the neovim environment";
      };
    };
  };
}

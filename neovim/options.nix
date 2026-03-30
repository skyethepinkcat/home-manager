{ lib, ... }:
{
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

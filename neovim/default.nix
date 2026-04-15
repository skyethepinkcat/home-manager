{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixvim-config.homeModules.default
  ];
  config = {
    programs = {
      nixvim = {
        enable = true;
        profiles.ai = true;
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

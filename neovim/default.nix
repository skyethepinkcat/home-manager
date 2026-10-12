{
  pkgs,
  lib,
  inputs,
  host,
  ...
}:
let
  nixvim_module =
    if host.hasTags "low power" then
      inputs.nixvim-config.homeModules.simple
    else
      inputs.nixvim-config.homeModules.default;

in
{
  imports = [
    nixvim_module
  ]
    # The simple nixvim module doesn't have AI options.
  ++ lib.optionals (!host.hasTags "low power") [
    {
      programs.nixvim.ai = {
        default = "claude";
        suggestions = false;
      };
    }

  ];
  programs = {
    nixvim = {
      enable = true;
    };

    neovide = {
      enable = host.hasTags "desktop";
      settings = {
        fork = true;
      };
    };
  };

}

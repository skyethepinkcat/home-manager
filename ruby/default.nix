{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    rbenv = {
      enable = false;
    };
  };
}

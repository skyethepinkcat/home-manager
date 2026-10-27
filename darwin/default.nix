{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  imports =
    with builtins;
    with lib;
    map (fn: ./${fn}) (
      filter (fn: (fn != "default.nix" && hasSuffix ".nix" "${fn}") || pathExists ./${fn}/default.nix) (
        attrNames (readDir ./.)
      )
    );
  config = lib.mkIf isDarwin {
    services.podman = {
      enable = true;
      machines = {
        "podman-machine-default" = {
          volumes = [
            "/Users:/Users"
            "/private:/private"
            "/var/folders:/var/folders"
          ];
          autoStart = true;
        };
      };
    };
    targets.darwin = {
      search = "DuckDuckGo";
      defaults = {
        "com.apple.finder" = {
          ShowPathBar = true;
          ShowStatusBar = true;
          AppleShowAllExtensions = true;
        };
        "com.apple.menuextra.clock" = {
          Show24Hour = true;
          IsAnalog = false;
          ShowDayOfWeek = false;
        };
        NSGlobalDomain.AppleShowAllExtensions = null;
      };
    };
    home.packages =
      with pkgs; [
        claude
        claude-usage-tracker
        iterm2
      ];
  };
}

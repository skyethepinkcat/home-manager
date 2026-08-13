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
      (with pkgs; [
        claude
        claude-usage-tracker
      ])
      ++ [
        (pkgs.iterm2.overrideAttrs rec {
          version = "3.6.11";

          # Remove when https://github.com/NixOS/nixpkgs/pull/540605 is merged
          src = pkgs.fetchzip {
            url = "https://iterm2.com/downloads/stable/iTerm2-${
              lib.replaceStrings [ "." ] [ "_" ] version
            }.zip";
            hash = "sha256-01QKUiXtL4WCq174sT/A5+iqmXe8HZt/Vih02spVRRs=";
          };
        })
      ];
  };
}

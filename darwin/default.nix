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
    home.packages = with pkgs; [
    claude
    claude-usage-tracker
    ];
  };
}

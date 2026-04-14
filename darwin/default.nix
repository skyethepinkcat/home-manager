{
  lib,
  config,
  ...
}:
let
  cfg = config.darwinConfig;
in
{
  config = lib.mkIf cfg.enable {
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
  };
  options = {
    darwinConfig.enable = lib.mkEnableOption "Enable Module";
  };
}

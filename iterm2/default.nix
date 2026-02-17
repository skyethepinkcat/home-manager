{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.iterm2-shell-integration;

  initFish = if cfg.enableInteractive then "interactiveShellInit" else "shellInitLast";
in
{
  meta.maintainers = [ ];

  options.programs.iterm2shell = {
    enable = lib.mkEnableOption "iterm2shell";

    package = lib.mkPackageOption pkgs "iterm2-shell-integration" { };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableIonIntegration = lib.hm.shell.mkIonIntegrationOption { inherit config; };

    enableNushellIntegration = lib.hm.shell.mkNushellIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
      if [[ $TERM != "dumb" ]]; then
        eval "$(${lib.getExe cfg.package} init bash --print-full-init)"
      fi
    '';

    programs.zsh.initContent = mkIf cfg.enableZshIntegration ''
      if [[ $TERM != "dumb" ]]; then
        eval "$(${lib.getExe cfg.package} init zsh)"
      fi
    '';

    programs.fish.${initFish} = mkIf cfg.enableFishIntegration ''
      if test "$TERM" != "dumb"
        ${lib.getExe cfg.package} init fish | source
        ${lib.optionalString cfg.enableTransience "enable_transience"}
      end
    '';

    programs.ion.initExtra = mkIf cfg.enableIonIntegration ''
      if test $TERM != "dumb"
        eval $(${lib.getExe cfg.package} init ion)
      end
    '';

    programs.nushell = mkIf cfg.enableNushellIntegration {
      # Unfortunately nushell doesn't allow conditionally sourcing nor
      # conditionally setting (global) environment variables, which is why the
      # check for terminal compatibility (as seen above for the other shells) is
      # not done here.
      extraConfig = ''
        use ${
          pkgs.runCommand "starship-nushell-config.nu" { } ''
            ${lib.getExe cfg.package} init nu >> "$out"
          ''
        }
      '';
    };
  };
}

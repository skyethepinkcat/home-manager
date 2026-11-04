{
  pkgs,
  inputs,
  config,
  lib,
  host,
  ...
}:
let
  claude-prompt = inputs.claude-prompt.packages."${pkgs.stdenv.hostPlatform.system}".default;
  enable = !host.hasTags "low power";
in
{
  imports = [
    inputs.skyepkgs.homeManagerModules.opencode-monitor
  ];
  sops.secrets.litellm_gateway = { };
  programs = {

    claude-code = {
      inherit enable;
      mutableSettings = true;
      settings = {
        statusLine = {
          type = "command";
          command = "${pkgs.lib.getExe claude-prompt}";
        };
        permissions = {
          allow = [
            "Bash(nix build:*)"
            "Bash(git add:*)"
            "Bash(claude mcp:*)"
          ];

        };
        enabledPlugins = {
          "github@claude-plugins-official" = true;
          "feature-dev@claude-plugins-official" = true;
          "commit-commands@claude-plugins-official" = true;
          "claude-code-setup@claude-plugins-official" = true;
          "caveman@caveman" = true;
        };
        extraPackages = with pkgs; [
          nodejs
        ];
        extraKnownMarketplaces = {
          "caveman" = {
            "source" = {
              "source" = "github";
              "repo" = "JuliusBrussee/caveman";
            };
          };
        };
      };
    };
  };
}

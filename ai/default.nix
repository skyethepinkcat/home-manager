{
  pkgs,
  ...
}:
let
  claude-statusline = pkgs.callPackage ./statusline/package.nix { };
in
{
  programs.claude-code = {
    enable = true;
    settings = {
      statusLine = {
        type = "command";
        command = "${pkgs.lib.getExe claude-statusline}";
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
}

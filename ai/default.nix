{
  pkgs,
  inputs,
config,
  ...
}:
let
  claude-prompt = inputs.claude-prompt.packages."${pkgs.stdenv.hostPlatform.system}".default;
  catppuccin-opencode = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "opencode";
    rev = "eebee30512751c898ff35ae43a4db6fe67e83330";
    hash = "sha256-Gf+YdT3dW5NnwOHbDD2O5y0JVsbYhD1MEHVwjd/Tq7g=";
  };
  rtk-src = pkgs.fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "46fa31c4b8a60f8f9b1e767b87dba6f54dd9e901";
    hash = "sha256-OxbtAA/NYien4+D0GelEzrnec6XyTF1e/6qOWl6Bw4k=";
  };
in
{
  sops.secrets.litellm_gateway = { };
  programs = {
    opencode-monitor = {
      enable = true;
      package = pkgs.opencode-monitor;
      settings = {
        paths = {
          database_file = "~/.local/share/opencode/opencode-stable.db";
        };
      };
    };
    opencode = {
      enable = true;
      tui.theme = "catppuccin";
      extraPackages = with pkgs; [
        rtk
      ];

      themes = "${catppuccin-opencode}/themes";
      context = ''
        Terse like caveman. Technical substance exact. Only fluff die.
        Drop: articles, filler (just/really/basically), pleasantries, hedging.
        Fragments OK. Short synonyms. Code unchanged.
        Pattern: [thing] [action] [reason]. [next step].
        ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
        Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".
      '';
      settings = {
        autoupdate = false;
        plugin = [
          "opencode-caveman"
          "${rtk-src}/hooks/opencode"
        ];
        provider = {
          litellm = {
            npm = "@ai-sdk/openai-compatible";
            name = "LiteLLM";
            options = {
              baseURL = "{file:${config.sops.secrets.litellm_gateway.path}}";
            };
            models = {
              "Claude Sonnet 4.6" = {
                name = "Claude Sonnet 4.6";
                cost = {
                  input = 3.00;
                  output = 15.00;
                };
              };
              "gemini-3-flash-preview" = {
                name = "gemini-3-flash-preview";
              };
              "GPT-5.4-nano" = {
                name = "GPT-5.4-nano";
              };
              "gpt-oss:120b" = {
                name = "gpt-oss:120b";
              };
              "Claude Haiku 4.5" = {
                name = "Claude Haiku 4.5";
              };
              "llama4:16x17b" = {
                name = "llama4:16x17b";
              };
              "QWEN3-Next-Coder 80B" = {
                name = "QWEN3-Next-Coder 80B";
              };
              "Llama4 Maverick" = {
                name = "Llama4 Maverick";
              };
              "GPT-5.4-mini" = {
                name = "GPT-5.4-mini";
              };
            };
          };
        };
      };
    };

    claude-code = {
      enable = true;
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
        hooks = {
          PreToolUse = [
            {
              "hooks" = [
                {
                  "command" = "/Users/ii69854/.claude/hooks/snip-rewrite.sh";
                  "type" = "command";
                }
              ];
              "matcher" = "Bash";
            }
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
          snip
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

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
      agents = {
        intern = ''
          ---
          description: Simple coding tasks — edits, small features, boilerplate
          mode: subagent
          model: litellm/QWEN3-Next-Coder 80B
          temperature: 0.2
          ---

          You handle simple, well-defined coding tasks: small edits, boilerplate, renaming, formatting fixes, obvious bug patches.

          Rules:
          - Ask for clarification before starting if the task is ambiguous
          - Do not refactor beyond what was asked
          - Do not add error handling, abstractions, or features beyond the request
          - If the task turns out to be complex, say so instead of attempting it
        '';
      };

      themes = "${catppuccin-opencode}/themes";
      context = ''
        Terse like caveman. Technical substance exact. Only fluff die.
        Drop: articles, filler (just/really/basically), pleasantries, hedging.
        Fragments OK. Short synonyms. Code unchanged.
        Pattern: [thing] [action] [reason]. [next step].
        ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
        Code/commits/PRs: normal.
        Off: "stop caveman" / "normal mode".
      '';
      settings = {
        autoupdate = false;
        plugin = [
          "opencode-caveman"
          # Adding rtk declaratively really doesn't want to work, make sure to use rtk init
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
                thinking = true;
                temperature = true;
                attachment = true;
                tool_calling = true;
                reasoning = true;

                cost = {
                  input = 3.30;
                  output = 16.50;
                };
              };
              "gemini-3-flash-preview" = {
                name = "gemini-3-flash-preview";
                cost = {
                  input = 0.50;
                  output = 3.00;
                };
              };
              "GPT-5.4-nano" = {
                name = "GPT-5.4-nano";
                cost = {
                  input = 0.20;
                  output = 1.25;
                };
              };
              "Claude Haiku 4.5" = {
                name = "Claude Haiku 4.5";
                cost = {
                  input = 1.10;
                  output = 5.50;
                };
              };
              "QWEN3-Next-Coder 80B" = {
                name = "QWEN3-Next-Coder 80B";
                cost = {
                  input = 0.09;
                  output = 0.25;
                };
              };
              "Llama4 Maverick" = {
                name = "Llama4 Maverick";
                cost = {
                  input = 0.24;
                  output = 0.97;
                };
              };
              "GPT-5.4-mini" = {
                name = "GPT-5.4-mini";
                cost = {
                  input = 0.75;
                  output = 4.50;
                };
              };
            };
          };
        };
        agent = {
          # Lightweight read-only subagents — no need for Sonnet
          explore = { model = "litellm/QWEN3-Next-Coder 80B"; };
          scout = { model = "litellm/QWEN3-Next-Coder 80B"; };
          # Planning/analysis — Haiku sufficient, better reasoning than nano
          plan = { model = "litellm/Claude Haiku 4.5"; };
          general = { model = "litellm/Claude Haiku 4.5"; };
          # Hidden system agents — mechanical tasks, cheapest viable model
          title = { model = "litellm/GPT-5.4-nano"; };
          summary = { model = "litellm/GPT-5.4-mini"; };
          compaction = { model = "litellm/GPT-5.4-mini"; };
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
        enabledPlugins = {
          "github@claude-plugins-official" = true;
          "feature-dev@claude-plugins-official" = true;
          "commit-commands@claude-plugins-official" = true;
          "claude-code-setup@claude-plugins-official" = true;
          "caveman@caveman" = true;
        };
        extraPackages = with pkgs; [
          rtk
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

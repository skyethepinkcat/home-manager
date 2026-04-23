{
  pkgs,
  inputs,
  ...
}:
let
  claude-prompt = inputs.claude-prompt.packages."${pkgs.stdenv.hostPlatform.system}".default;
in
{
  # UHHHHHHH this might be causing department chargebacks maybe don't do that.
  programs.opencode = {
    enable = false;
    settings = {
      provider = {
        litellm = {
          npm = "@ai-sdk/openai-compatible";
          name = "LiteLLM";
          options = {
            baseURL = "";
          };
          models = {
            "Claude Sonnet 4.6" = {
              name = "Claude Sonnet 4.6";
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

  programs.claude-code = {
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

{
  pkgs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    settings = {
      statusLine = {
        type = "command";
        command =
          # bash
          ''
            caveman_text=""
            caveman_flag="$HOME/.claude/.caveman-active"
            if [ -f "$caveman_flag" ]; then
              caveman_mode=$(cat "$caveman_flag" 2>/dev/null)
              if [ "$caveman_mode" = "full" ] || [ -z "$caveman_mode" ]; then
                caveman_text=" [CAVEMAN]"
              else
                caveman_suffix=$(echo "$caveman_mode" | tr '[:lower:]' '[:upper:]')
                caveman_text=" [CAVEMAN:''${caveman_suffix}]"
              fi
            fi
            input=$(cat)
            model=$(printf '%s' "$input" | ${pkgs.lib.getExe pkgs.jq} -r '.model.display_name // "unknown"')
            ctx_pct=$(printf '%s' "$input" | ${pkgs.lib.getExe pkgs.jq} -r '(.context_window.used_percentage // 0) | floor')
            rl_pct=$(printf '%s' "$input" | ${pkgs.lib.getExe pkgs.jq} -r '(.rate_limits.five_hour.used_percentage // 0) | floor')
            resets_at=$(printf '%s' "$input" | ${pkgs.lib.getExe pkgs.jq} -r '.rate_limits.five_hour.resets_at // empty')
            if [ "$ctx_pct" -lt 50 ]; then
              ctx_color="\033[32m"
            elif [ "$ctx_pct" -lt 75 ]; then
              ctx_color="\033[33m"
            else
              ctx_color="\033[31m"
            fi
            if [ "$rl_pct" -lt 50 ]; then
              rl_color="\033[32m"
            elif [ "$rl_pct" -lt 75 ]; then
              rl_color="\033[33m"
            else
              rl_color="\033[31m"
            fi
            if [ -n "$resets_at" ]; then
              reset_time=$(${pkgs.lib.getExe' pkgs.coreutils "date"} -d "@$resets_at" "+%H:%M" 2>/dev/null)
              rl_label="$rl_pct% 󰓅 until $reset_time"
            else
              rl_label="$rl_pct% 󰓅"
            fi
            weekly_pct=$(printf '%s' "$input" | ${pkgs.lib.getExe pkgs.jq} -r '(.rate_limits.seven_day.used_percentage // 0) | floor')
            weekly_resets=$(printf '%s' "$input" | ${pkgs.lib.getExe pkgs.jq} -r '.rate_limits.seven_day.resets_at // empty')
            if [ -n "$weekly_resets" ]; then
              now=$(${pkgs.lib.getExe' pkgs.coreutils "date"} +%s)
              week_start=$((weekly_resets - 604800))
              elapsed_pct=$(( (now - week_start) * 100 / 604800 ))
              if [ "$weekly_pct" -gt "$elapsed_pct" ]; then
                printf '\033[91m⚠️ weekly: %s%% (expected <=%s%%)\033[0m\n' "$weekly_pct" "$elapsed_pct"
              fi
            fi
            case "$model" in
              *[Ss]onnet*)
                printf "''${caveman_text} ''${ctx_color}[%s%% context]\033[0m ''${rl_color}[%s]\033[0m\n" "$ctx_pct" "$rl_label"
                ;;
              *[Oo]pus*)
                printf "\033[31m %s\033[0m''${caveman_text} ''${ctx_color}[%s%% context]\033[0m ''${rl_color}[%s]\033[0m\n" "$model" "$ctx_pct" "$rl_label"
                ;;
              *)
                printf "\033[33m %s\033[0m''${caveman_text} ''${ctx_color}[%s%% context]\033[0m ''${rl_color}[%s]\033[0m\n" "$model" "$ctx_pct" "$rl_label"
                ;;
            esac
          '';
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

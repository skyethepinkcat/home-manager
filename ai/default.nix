{pkgs,...
}: {
  programs.claude-code = {
    enable = true;
    settings = {
      statusLine = {
        type = "command";
        command = "${pkgs.jq} -r '\"[\\(.model.display_name)] \\(.context_window.used_percentage // 0)% context\"'";
      };
    };
  };

}

{
  pkgs,
  config,
  lib,
  ...
}: rec {
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    zprof.enable = false; # Enable to profile startup performance.
    completionInit = ''
      autoload -Uz compinit
      if [ "$(find ${programs.zsh.dotDir}/.zcompdump -mtime +1)" ] ; then
        echo regenerating
          compinit
      fi
      compinit -C
    '';

    history = {
      append = true;
      save = 10000;
      size = 10000;
      expireDuplicatesFirst = true;
      share = true;
      path = "${programs.zsh.dotDir}/history";
      ignoreSpace = true;
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = ["^[[A" "^P"];
      searchDownKey = ["^[[B" "^N"];
    };
    defaultKeymap = "emacs";

    # syntaxHighlighting = {
    #   enable = true;
    # };
    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "3922b91";
          sha256 = "sha256-RYLPOguM6YS7RK2AU6QdDCtdwezzOpJYixIEIAU/UPY=";
        };
        file = "fast-syntax-highlighting.plugin.zsh";
      }
    ];

    initContent = let
      # Functions to set the window title.
      normalTitle = lib.mkOrder 1000 (lib.readFile ./win_title_functions.zsh);
      lateTitle = lib.mkOrder 1500 "precmd_functions+=(set_win_title)";
    in
      lib.mkMerge [normalTitle lateTitle];
  };
}

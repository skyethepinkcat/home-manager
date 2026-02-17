{
  pkgs,
  username,
  inputs,
  ...
}:
let
  is_darwin =
    if builtins.match ".*-(darwin|linux)" pkgs.stdenv.hostPlatform.system == [ "darwin" ] then
      true
    else
      false;
  shell-script =
    {
      script,
      depends ? [ ],
      extraOptions ? { }, # Pass raw options to writeShellApplication
      ...
    }:
    pkgs.callPackage pkgs.writeShellApplication (
      {
        name = "${script}";
        runtimeInputs = depends;

        text = builtins.readFile ./files/scripts/${script}.sh;
      }
      // extraOptions
    );
in
rec {
  imports = [
    ./zsh
    ./vim
    ./starship
    ./darwin
    ./neovim
  ];
  darwinConfig.enable = is_darwin;
  xdg = {
    enable = true;
    #    configHome = homedir + ".config";
  };

  neovim-config.enable = true;
  neovim-config.packages = with pkgs; [
    nil
    nodePackages.bash-language-server
    nixfmt
    rubocop
    solargraph
  ];

  # Look up home manager options here
  # https://home-manager-options.extranix.com
  home = {
    username = username;
    homeDirectory = if is_darwin then "/Users/${home.username}" else "/home/${home.username}";

    sessionPath = [
      "${home.homeDirectory}/.local/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      "/opt/homebrew/opt/openjdk/bin"
    ];

    sessionVariables = {
      BAT_THEME = "Catppuccin Mocha";
      CSEE_USER = home.username;
      JAVA_HOME = "/opt/homebrew/opt/openjdk";
    };

    packages =
      with pkgs;
      [
        bash-language-server
        coreutils
        lazygit
        findutils
        ffmpeg
        fd
        gnused
        gnutar
        mpv
        openssl
        ripgrep
        rsync
        rustup
        treefmt
        neovide
        wireshark
        nil
      ]
      ++ [
        (shell-script {
          script = "forgethost";
          depends = with pkgs; [ gnused ];
        })
        (shell-script {
          script = "sniff";
          depends = with pkgs; [
            openssh
            wireshark
          ];
        })
        (shell-script {
          script = "puppet-fmt";
          extraOptions.bashOptions = [ "nounset" ];
        })
        (shell-script {
          script = "nr";
        })
        (shell-script {
          script = "ns";
        })
        inputs.nixvim-config.packages.${pkgs.system}.default
      ];
    #
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.11";

    shellAliases = {
      peek = "it2cat";
      ll = "ls -l";
      nixconfig = "nvim ~/Projects/nix-config";
      nvimconfig = "nvim ~/.config/nvim";
      neovim = "nvim";
      ckan = "ckan consoleui";
    };
  };

  programs = {
    gcc.enable = true;
    yazi = {
      enable = true;
      shellWrapperName = "yy";
    };

    bash.enable = true;

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      theme = builtins.fromJSON (builtins.readFile ./themes/eza/mocha/catppuccin-mocha-blue.json);
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      ignores = [
        ".DS_Store"
        ".mise*"
        ".vscode"
        ".gitlint"
        ".gitignore.local"
      ];
      settings = {
        push.autoSetupRemote = true;
        user = {
          name = "Skye J";
          email = "skye@skyenet.online";
        };
      };
    };

    home-manager.enable = true;
  };
}

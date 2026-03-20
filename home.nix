{
  pkgs,
  username,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  is_darwin = if builtins.match ".*-(darwin|linux)" system == [ "darwin" ] then true else false;
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

  neovim-config = {
    enable = true;
    use-nvchad = false;
    use-nixvim = true;
    packages = with pkgs; [
      nil
      nodePackages.bash-language-server
      nixfmt
      mmv
      rubocop
      solargraph
    ];
  };

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
      RUBY_YJIT_ENABLE = 1;
      CSEE_USER = home.username;
      JAVA_HOME = "/opt/homebrew/opt/openjdk";
    };

    packages =
      with pkgs;
      [
        bash-language-server
        coreutils
        gnupg
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
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "alborz.cs.umbc.edu vision*.cs.umbc.edu secrets.cs.umbc.edu" = {
          user = "skye";
          identityFile = "~/.ssh/umbc_id_rsa";
          identityAgent = "~/Library/Group\\ Containers/group.strongbox.mac.mcguill/agent.sock";
        };
        "ebserv2.cs.umbc.edu" = {
          user = "skyejonke";
          identityFile = "~/.ssh/umbc_id_rsa";
          identityAgent = "~/Library/Group\\ Containers/group.strongbox.mac.mcguill/agent.sock";
          addKeysToAgent = "yes";
        };
        "*.umbc.edu" = {
          user = "ii69854";
          identityFile = "~/.ssh/umbc_id_rsa";
          identityAgent = "~/Library/Group\\ Containers/group.strongbox.mac.mcguill/agent.sock";
          addKeysToAgent = "yes";
          sendEnv = [ "CSEE_USER" ];
          checkHostIP = false;
          extraOptions = {
            "hostkeyAlgorithms" = "+ssh-rsa";
            "pubkeyAcceptedKeyTypes" = "+ssh-rsa";
          };
        };
        "honnoji asticassia lydian mayfaire skyenet.online" = {
          user = "skye";
        };
        "*" = {
          sendEnv = [ "COLORTERM" ];
          identityFile = "~/.ssh/id_ed25519";
          identityAgent = "~/Library/Group\\ Containers/group.strongbox.mac.mcguill/agent.sock";
          addKeysToAgent = "yes";
        };
      };
    };
    lazygit = {
      enable = true;
      settings = {
        theme = {
          activeBorderColor = [
            "#89b4fa"
            "bold"
          ];
          inactiveBorderColor = [ "#a6adc8" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
        };
        authorColors = {
          "*" = "#b4befe";
        };
      };
    };
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

    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
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

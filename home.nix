{
  pkgs,
  username,
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
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
    inputs.sops-nix.homeManagerModules.sops
    ./packages.nix
    ./zsh
    ./vim
    ./starship
    ./darwin
    ./ai
    ./neovim
  ];

  darwinConfig.enable = is_darwin;

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets.anthropic_api_key = { };
  };

  xdg = {
    enable = true;
    #    configHome = homedir + ".config";
  };

  # Look up home manager options here
  # https://home-manager-options.extranix.com
  home = {
    inherit username;
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
      LS_COLORS = "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:";
    };

    sessionVariablesExtra = ''
      export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic_api_key.path} 2>/dev/null || true)"
    '';

    # Place "real" packages in ./packages.nix
    packages = [
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
    stateVersion = "26.05";

    shellAliases = {
      peek = "it2cat";
      ll = "ls -l";
      neovim = "nvim";
      ckan = "ckan consoleui";
      flake = "nix flake";
    };
  };

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "alborz.cs.umbc.edu vision*.cs.umbc.edu secrets.cs.umbc.edu" =
          lib.hm.dag.entryBefore [ "*.umbc.edu" ]
            {
              user = "skye";
              identityFile = "~/.ssh/umbc_id_rsa";
              identityAgent = "~/Library/Group\\ Containers/group.strongbox.mac.mcguill/agent.sock";
            };
        "ebserv2.cs.umbc.edu" = lib.hm.dag.entryBefore [ "*.umbc.edu" ] {
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
        gui = {
          theme = {
            activeBorderColor = [
              "#89b4fa"
              "bold"
            ];
            inactiveBorderColor = [ "#a6adc8" ];
            searchingActiveBorderColor = [ "#f9e2af" ];
            optionsTextColor = [ "#89b4fa" ];
            selectedLineBgColor = [ "#313244" ];
            inactiveViewSelectedLineBgColor = [ "#6c7086" ];
            cherryPickedCommitFgColor = [ "#89b4fa" ];
            cherryPickedCommitBgColor = [ "#45475a" ];
            markedBaseCommitFgColor = [ "#89b4fa" ];
            markedBaseCommitBgColor = [ "#f9e2af" ];
            unstagedChangesColor = [ "#f38ba8" ];
            defaultFgColor = [ "#cdd6f4" ];
          };
          authorColors = {
            "*" = "#b4befe";
          };
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
      font = {
        name = "Hack Nerd Font Mono";
        size = 14;
        package = pkgs.nerd-fonts.hack;
      };

    };

    git = {
      enable = true;
      ignores = [
        ".DS_Store"
        ".mise*"
        ".vscode"
        ".gitlint"
        ".gitignore.local"
        ".direnv"
        ".claude/configuration.local.json"
      ];
      settings = {
        push.autoSetupRemote = true;
        init.defaultBranch = "main";
        core.repositoryFormatVersion = 1;
        extensions.refStorage = "reftable";
        user = {
          name = "Skye J";
          email = "skye@skyenet.online";
        };
      };
    };

    home-manager.enable = true;
  };
  programs.nh = {
    enable = true;
    homeFlake = "~/Configuration/home-manager";
    darwinFlake = "~/Configuration/nix";
    osFlake = "~/Configuration/nix";
  };
  nixpkgs.config.allowUnfree = true;
  nix.registry = {
    nixvim = {
      from = {
        id = "nixvim";
        type = "indirect";
      };
      to = {
        path = "${config.home.homeDirectory}/Configuration/nixvim";
        type = "path";
      };
    };
  };
}

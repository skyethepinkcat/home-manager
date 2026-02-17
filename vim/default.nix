{
  config,
  lib,
  pkgs,
  ...
}:
let
  catppuccin-vim = pkgs.vimUtils.buildVimPlugin {
    name = "catppuccin-vim";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "vim";
      rev = "fc2e9d853208621a94ec597c50bf559875bf6d99";
      sha256 = "01yl0pxgdmwv8lwzv1g9chxw8ba3r678glgy5pb1c34zqll597q2";
    };
  };
in
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    settings = {
      relativenumber = true;
      ignorecase = true;
      smartcase = true;
      history = 1000;
      shiftwidth = 4;
      tabstop = 4;
      expandtab = true;
    };
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-commentary
      vim-nix
      vim-puppet
      catppuccin-vim
    ];
    extraConfig = ''
      set showmode
      set showmatch
      set hlsearch
      colorscheme catppuccin_mocha
      set nowrap
      set autoindent
      set nobackup
      set incsearch
      set showcmd
      " Don't wait for the x display on macos - severely hurts startup time
      if $DISPLAY =~ '.*xquartz.*'
       set clipboard=autoselect,exclude:.*
      endif
    '';
  };
}

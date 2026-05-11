{
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.system == "aarch64-darwin";
  vimpkg = if isDarwin then pkgs.vim-darwin else pkgs.vim-full;
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
    packageConfigurable = vimpkg;
    settings = {
      relativenumber = true;
      ignorecase = true;
      smartcase = true;
      history = 1000;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-commentary
      vim-nix
      vim-puppet
      vim-surround
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
      set clipboard=unnamed
    '';
  };
}

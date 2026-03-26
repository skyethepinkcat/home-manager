{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bash-language-server
    coreutils
    gnupg
    findutils
    ffmpeg
    fd
    gnused
    gnutar
    mpv
    gitflow
    openssl
    ripgrep
    rsync
    rustup
    wireshark
    nil
  ];
}

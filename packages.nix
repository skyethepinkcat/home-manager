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
    openssl
    ripgrep
    rsync
    rustup
    treefmt
    wireshark
    nil
  ];
}

{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    bash-language-server
    # bat-extras.batman
    bat-extras.core
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
    claude-agent-acp
  ];

}

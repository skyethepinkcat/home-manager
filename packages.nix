{ pkgs, lib, inputs, ... }:
{
  home.packages = with pkgs; [
    bash-language-server
    claude-code
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

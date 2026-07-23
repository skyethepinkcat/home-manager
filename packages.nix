{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      age-plugin-yubikey
      bash-language-server
      bat-extras.core
      claude-agent-acp
      coreutils
      fd
      ffmpeg
      findutils
      gh-dash
      gnupg
      gnused
      gnutar
      mpv
      nil
      nvd
      openssl
      ripgrep
      rsync
      rtk
      sops
      watch
      wireshark
    ]
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ trash-cli ];
}

{
  pkgs,
  lib,
  inputs,
  host,
  ...
}:
{
  home.packages =
    (with pkgs; [
      age-plugin-yubikey
      bash-language-server
      bat-extras.core
      claude-agent-acp
      coreutils
      fd
      ffmpeg
      findutils
      gh-dash
      gnugrep
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
    ])
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) (with pkgs; [ trash-cli ])
    ++ lib.optionals (host.hasTags [ "desktop" ]) (
      with pkgs;
      [
        mpv
        obsidian
        wireshark
        discord
        element-desktop
      ]
    );
}

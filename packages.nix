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
      (kpcli.overrideAttrs (
        prev: final: {
          installPhase = ''
            mkdir -p $out/{bin,share}
            cp ${final.src} $out/share/kpcli.pl
            chmod +x $out/share/kpcli.pl

            makeWrapper $out/share/kpcli.pl $out/bin/kpcli --set PERL5LIB \
              "${
                with perlPackages;
                makePerlPath (
                  [
                    BHooksEndOfScope
                    CaptureTiny
                    Clipboard
                    Clone
                    CryptRijndael
                    CryptX
                    DevelGlobalDestruction
                    ModuleImplementation
                    ModuleRuntime
                    SortNaturally
                    SubExporterProgressive
                    TermReadKey
                    TermShellUI
                    TryTiny
                    FileKDBX
                    FileKeePass
                    PackageStash
                    RefUtil
                    TermReadLineGnu
                    boolean
                    namespaceclean
                    CryptArgon2
                    IteratorSimple
                    ScopeGuard
                    XMLLibXML
                    XMLParser
                    XMLSAXBase
                  ]
                  ++ lib.optional stdenv.hostPlatform.isDarwin MacPasteboard
                )
              }"
          '';

        }
      ))
    ])
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) (with pkgs; [ trash-cli ])
    ++ lib.optionals (host.hasTags [ "desktop" ]) (
      with pkgs;
      [
        discord
        element-desktop
        mpv
        obsidian
        pandoc
        texliveMedium
        wireshark
      ]
    );
}

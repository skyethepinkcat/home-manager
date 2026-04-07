{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  rad = with pkgs; buildGoModule (finalAttrs: rec {
    pname = "rad";
    version = "0.9.2";
    src = fetchFromGitHub {
      owner = "amterp";
      repo = "rad";
      tag = "v${version}";
      hash = "sha256-+sB+Nes+ir20HG86bYTYeSfcufk7XGEuizE2UlLvOL4=";
    };
    vendorHash = "sha256-BbLT3EHUbV7t1Ghm6nc7zne8dQqYq3Ipi4W+rUshGh8=";

    excludedPackages = [
      "textmate-gen" # Not a go module?
    ];
    proxyVendor = true;
    checkFlags = [
      # Depends on Filesystem.
      "-skip=TestSnapshots/functions/get_path/GetPath_ModifiedMillis"
    ];

    meta = {
      description = "A Scripting Language to make Modern CLI Scripts Easy";
      homepage = "https://github.com/amterp/rad";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ skyethepinkcat ];
    };
  });
in
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
    rad
  ];


}

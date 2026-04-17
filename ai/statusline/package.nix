{
  pkgs,
  lib
}:
let
  ruby = pkgs.ruby.withPackages (ps: with ps;[ git rainbow ]);
in
pkgs.stdenv.mkDerivation {
  pname = "claude-statusline";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/claude-statusline $out/bin
    cp statusline.rb $out/share/claude-statusline/statusline.rb
    makeWrapper ${ruby}/bin/ruby $out/bin/claude-statusline \
      --add-flags "$out/share/claude-statusline/statusline.rb"
  '';

  meta = {
    description = "Claude Code statusline renderer";
    mainProgram = "claude-statusline";
  };
}

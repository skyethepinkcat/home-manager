{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  targets.darwin.defaults = {
    "com.apple.universalaccess"."com.apple.custommenu.apps" = [
      "NSGlobalDomain"
      "com.googlecode.iterm2"
      "org.nixos.thunderbird"
      "com.apple.Safari"
    ];
    "com.apple.symbolichotkeys"."AppleSymbolicHotKeys" = {
      # Siri "Ask about this window" hotkey, the default doesn't work with strongbox.
      "263".enabled = 0;
    };
    "com.apple.safari".NSUserKeyEquivalents = {
      # Command+Q closes the window rather than the application for Safari.
      "Close Window" = "@q";
    };
    "org.nixos.thunderbird".NSUserKeyEquivalents = {
      # Press F10 to open message filters.
      # See /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/AppKit.framework/Headers/NSEvent.h
      "Message Filters" = "\\Uf70d";
      "Account Settings" = "@$,";
    };
  };
}

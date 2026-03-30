{ lib, ... }:
{
  programs.ssh.enable = lib.mkForce false; # Points to ssh keys that are different on other systems
  programs.zsh.dotDir = lib.mkForce null; # Most systems don't support ~/.config/zsh
}

{
  pkgs,
  lib,
  config,
  inputs,
  host,
  ...
}:
{
  sops.secrets.discord_tee_hook = { };
  home.packages = [

    (pkgs.writeShellApplication {
      name = "discord_tee";
      runtimeInputs = with pkgs; [
        coreutils
        curl
      ];

      text = ''
        #!/usr/bin/env bash
        DISCORD_WEBHOOK_URL="$(< ${config.sops.secrets.discord_tee_hook.path})"
        export DISCORD_WEBHOOK_URL
        ${inputs.discord_tee.defaultPackage.${host.system}}/bin/discord-tee
      '';

    })
  ];

}

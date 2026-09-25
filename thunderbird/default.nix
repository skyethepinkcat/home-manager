{
  host,
  pkgs,
  inputs,
  lib,
  config,
  ...

}:
let
  # Copied from https://github.com/thunderbird/thunderbird-desktop/blob/48dbe6464245432781b9f688bb03f0b8a8e15903/mailnews/search/public/nsMsgFilterCore.idl#L7
  # These may not be stable!!!
  #
  # MailTypes indicate when the filters are run.
  filterTypes = with lib; rec {
    None = fromHexString "0x00";
    InboxRule = fromHexString "0x01";
    InboxJavaScript = fromHexString "0x02";
    Inbox = bitOr InboxRule InboxJavaScript;
    NewsRule = fromHexString "0x04";
    NewsJavaScript = fromHexString "0x08";
    News = bitOr NewsRule NewsJavaScript;
    Incoming = bitOr Inbox News;
    Manual = fromHexString "0x10";
    PostPlugin = fromHexString "0x20"; # After bayes filtering
    PostOutgoing = fromHexString "0x40"; # After sending
    Archive = fromHexString "0x80"; # Before archiving
    Periodic = fromHexString "0x100"; # On a repeating timer
    All = bitOr Incoming Manual;
    __functor =
      self: first: second:
      toString (bitOr self."${first}" self.${second});
  };
  defaultSettings = id: {
    "mail.server.server_${id}.moveOnSpam" = true;
  };
  identitySettings = id: {
    "mail.identity.id_${id}.reply_on_top" = 1;
    "mail.identity.id_${id}.reply_sig" = true;
  };
in

{
  # imports = [ ./options.nix ];
  config = lib.mkIf (host.hasTags "desktop") {
    sops.secrets.icloud_mail_pw = { };
    # Sadly its not really possible to handle calendars because we would need to specify every
    # calendar manually, rather than just referencing a single account.
    accounts = {
      email.accounts = {
        "Apple Mail" = {
          realName = "Skye J";
          address = "skye@skyejonke.com";
          aliases = [
            "skye@skyenet.online"
            "skyejonke@icloud.com"
          ];
          folders = {
            trash = "Deleted Messages";
          };
          passwordCommand = "cat ${config.sops.secrets.icloud_mail_pw.path}";
          userName = "skyejonke@icloud.com";
          imap = {
            authentication = "plain";
            host = "imap.mail.me.com";
            port = 993;
            tls.enable = true;
          };
          smtp = {
            host = "smtp.mail.me.com";
            authentication = "plain";
            port = 587;
            tls = {
              enable = true;
              useStartTls = true;
            };
          };
          thunderbird =
            let
              # Sadly I couldn't find a decent way to determine this in eval
              folderName = "imap://skyejonke%40icloud.com@imap.mail.me.com";
            in
            {
              enable = true;
              profiles = [ "nix" ];
              perIdentitySettings = identitySettings;
              settings =
                id:
                {
                  "mail.identity.id_${id}.archive_folder" = "${folderName}/Archive";
                  "mail.server.server_${id}.spamActionTargetFolder" = "${folderName}/Junk";
                }
                // defaultSettings id;
              messageFilters = [
                {
                  name = "NixOS Discourse";
                  action = "Move to folder";
                  actionValue = "${folderName}/Mailing Lists/NixOS";
                  type = filterTypes "Manual" "Inbox";
                  condition = "AND (from,contains,discourse@discourse.nixos.org)";
                }
                {
                  name = "Verification Codes";
                  action = "Move to folder";
                  actionValue = "${folderName}/Verification Codes";
                  type = filterTypes "Manual" "Inbox";
                  condition = "AND (subject,contains,verification code)";
                }
              ];
            };
          primary = !host.hasTags "work";
        };
        "UMBC Gmail" = lib.mkIf (host.hasTags "work") {
          realName = "Skye Jonke";
          address = "ii69854@umbc.edu";
          aliases = [ "skyejonke@umbc.edu" ];
          flavor = "gmail.com";
          signature = {
            delimiter = ''
              ---
            '';
            text = ''
              Skye Jonke

              she/her

              Specialist, Linux System Administrator & Lab Technical Support

              410-455-2860
            '';
            # htmlFormat = true;
            showSignature = "append";
          };
          thunderbird =
            let
              folderName = "imap://ii69854%40umbc.edu@imap.gmail.com";
            in
            {
              enable = host.hasTags "desktop";
              profiles = [ "nix" ];
              settings = defaultSettings;
              perIdentitySettings = identitySettings;
              # directory = "UMBC LDAP";
              #
              messageFilters = [
                {
                  name = "Move to Spam";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/[Gmail]/Spam";
                  condition = "AND (junk status,is,2)";
                }
                {
                  name = "Redhat";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Redhat Notifications";
                  condition = "AND (from,contains,noreply@redhat.com)";
                }
                {
                  name = "Cron Daemon";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Cron";
                  condition = ''AND (filtaquilla@mesquilla.com#headerRegex,matches,\"sender:.*\(Cron Daemon\).*\")'';
                }
                {
                  name = "To Systems";
                  enabled = true;
                  type = filterTypes "Manual" "PostPlugin";
                  action = "Move to folder";
                  actionValue = "${folderName}/To Systems";
                  condition = "AND (to,contains,systems@cs.umbc.edu)";
                }
              ];
            };
          primary = host.hasTags "work";
        };
      };
    };
    programs.neomutt.enable = true;
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-esr;
      profiles = {
        "v4pwe35w.default-release" = { };
        nix = {
          # directories = {
          #   "UMBC LDAP" = {
          #     hostname = "directory.umbc.edu";
          #     baseDN = "ou=People,dc=umbc,dc=edu";
          #   };
          # };
          extraConfig =
            # Manual config until https://github.com/nix-community/home-manager/pull/9965 gets
            # merged.
            ''
              user_pref("ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738.auth.dn", "");
              user_pref("ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738.description", "UMBC LDAP");
              user_pref("ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738.filename", "ldap.sqlite");
              user_pref("ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738.maxHits", 100);
              user_pref("ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738.saslmech.dn", "");
              user_pref("ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738.uri", "ldap://directory.umbc.edu:389/ou=People,dc=umbc,dc=edu??sub?");
              user_pref("mail.identity.id_855d67c7583ccb92137542609e331cbaa76b6ae5253eaae2ef11095cbea3a65d.directoryServer", "ldap_2.servers.ldap_2a004ff74a45b0e57228fe16d2763709b803d7f52486a6f84adf5a525f346738");
            '';
          settings = {
            "extensions.autoDisableScopes" = 0;

            "extensions.filtaquilla.HeaderRegexEnabled" = true;
            "extensions.filtaquilla.SubjectBodyRegexEnabled" = true;
            "mail.spam.manualMark" = true;
            "mail.spam.markAsReadOnSpam" = true;
            "mail.shell.checkDefaultClient" = false;
          }
          // lib.optionalAttrs (host.hasTags "work") {
            "mail.pane_config.dynamic" = 1; # Wide message view, specific to work since I use a vertical monitor there.
          };
          extensions = [
            inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.rycee.thunderbird-addons.filtaquilla

          ];
          isDefault = true;
          accountsOrder = lib.optionals (host.hasTags "work") [ "UMBC Gmail" ] ++ [
            "Apple Mail"
          ];
        };

      };
    };

  };
}

{
  host,
  pkgs,
  inputs,
  lib,
  config,
  nur,
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
    PostPlugin = fromHexString "0x20"; # After bayes filtering, note that this DOES NOT need to be mixed with incoming
    PostOutgoing = fromHexString "0x40"; # After sending
    Archive = fromHexString "0x80"; # Before archiving
    Periodic = fromHexString "0x100"; # On a repeating timer
    All = bitOr Incoming Manual;
    __functor =
      self: first: second:
      toString (bitOr self."${first}" self.${second});
  };
  defaultSettings = id: {
    "mail.server.server_${id}.moveOnSpam" = false;
  };
  identitySettings = id: {
    "mail.identity.id_${id}.reply_on_top" = 1;
    "mail.identity.id_${id}.reply_sig" = true;
    "mail.identity.id_${id}.sig_bottom" = false;
    "mail.identity.id_${id}.fcc_reply_follows_parent" = true;
  };
  multiAction =
    filter: actions:

    let
      primaryAction = builtins.elemAt actions 0;
      otherActions = lib.lists.drop 1 actions;
    in
    filter
    // {
      inherit (primaryAction) action actionValue;
      extraConfig = lib.concatMapStrings (
        a:
        ''
          action="${a.action}"
        ''
        + lib.optionalString (builtins.hasAttr "actionValue" a) ''
          actionValue="${a.actionValue}"
        ''
      ) otherActions;
    };

  buildMozillaXpiAddon = nur.repos.rycee.lib.mozilla.mkBuildMozillaXpiAddon {
    inherit (pkgs) stdenv fetchurl;
  };
  importexportng = buildMozillaXpiAddon rec {
    pname = "import-export-ng";
    version = "15.0.3";
    addonId = "ImportExportToolsNG@cleidigh.kokkini.net";
    url = "https://github.com/thunderbird/import-export-tools-ng/releases/download/v${version}/import-export-tools-ng-${version}-tb.xpi";
    sha256 = "sha256-m+vvgX70JRxTNF/Vqd/CsrAL9Lpjqzjo9l/Hg/TNUYs=";
    meta = with lib; {
      homepage = "https://github.com/thunderbird/import-export-tools-ng";
      description = "";
      license = licenses.mpl20;
      mozPermissions = [
        "menus"
        "activeTab"
        "messagesRead"
        "tabs"
        "accountsFolders"
        "accountsRead"
        "messagesImport"
        "notifications"
        "messagesMove"
      ];
      platforms = platforms.all;
    };
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
                (defaultSettings id)
                // {
                  "mail.identity.id_${id}.archive_folder" = "${folderName}/Archive";
                  "mail.server.server_${id}.spamActionTargetFolder" = "${folderName}/Junk";
                  "mail.server.server_${id}.moveOnSpam" = true;
                };
              messageFilters = [
                {
                  name = "NixOS Discourse";
                  action = "Move to folder";
                  actionValue = "${folderName}/Mailing Lists/NixOS";
                  type = filterTypes "Manual" "Inbox";
                  condition = "AND (all addresses,contains,discourse@discourse.nixos.org)";
                }
                {
                  name = "KDE";
                  action = "Move to folder";
                  actionValue = "${folderName}/Mailing Lists/KDE";
                  type = filterTypes "Manual" "Inbox";
                  condition = "AND (all addresses,contains,@kde.org)";
                }
                {
                  name = "Github Notifications";
                  action = "Move to folder";
                  actionValue = "${folderName}/Notifications";
                  type = filterTypes "Manual" "Inbox";
                  condition = "AND (all addresses,contains,notifications@github.com)";
                }
                {
                  name = "Verification Codes";
                  action = "Move to folder";
                  actionValue = "${folderName}/Verification Codes";
                  type = toString filterTypes.All;
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
              settings = lib.mkMerge [
                defaultSettings
              ];
              perIdentitySettings = lib.mkMerge [

                identitySettings
                (id: {
                  "mail.identity.id_${id}.fcc_folder" = "${folderName}/[Gmail]/Sent Mail";

                })
              ];
              directory = "UMBC LDAP";
              messageFilters = [
                {
                  name = "Redhat";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Notifications/RedHat";
                  condition = "AND (all addresses,contains,noreply@redhat.com)";
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
                  name = "Voicemail";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Voicemail";
                  condition = ''AND (filtaquilla@mesquilla.com#subjectRegex,matches,\"Message from .*\([+\d]+\)\")'';
                }
                {
                  name = "To Systems";
                  enabled = true;
                  type = filterTypes "Manual" "InboxRule";
                  action = "Move to folder";
                  actionValue = "${folderName}/To Systems";
                  condition = "OR (all addresses,contains,systems@cs.umbc.edu) OR (all addresses,contains,systems@cs.umbc.edu) OR (to,contains,root@)";
                }
                {
                  name = "Mailing list request";
                  enabled = true;
                  type = filterTypes "Manual" "InboxRule";
                  action = "Move to folder";
                  actionValue = "${folderName}/To Systems";
                  condition = "AND (subject,contains,post from) AND (subject,contains,requres approval) AND (subject,contains,@cs.umbc.edu)";
                }
                {
                  name = "Capstone";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Capstone";
                  condition = "OR (subject,contains,capstone)";
                }
                {
                  name = "Alert Manager";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Notifications/Alert Manager";
                  condition = "OR (from,contains,alertmanager@cs.umbc.edu)";
                }
                {
                  name = "Amazon Shipping Notifications";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  action = "Move to folder";
                  actionValue = "${folderName}/Notifications/Shipping";
                  condition = "OR (from,contains,shipment-tracking@amazon.com) OR (from,contains,order-update@amazon.com)";
                }
                {
                  name = "UMBC Not Spam";
                  enabled = true;
                  type = filterTypes "PostPlugin" "Manual";
                  action = "JunkScore";
                  actionValue = "0";
                  condition = "OR (from,contains,@umbc.edu) OR (from,contains,@cs.umbc.edu) OR (from,contains,@csee.umbc.edu)";
                }
                (multiAction
                  {
                    name = "myumbc notifications";
                    enabled = true;
                    type = filterTypes "InboxRule" "Manual";
                    condition = "OR (from,contains,@my.umbc.edu)";
                  }
                  [
                    {
                      action = "Move to folder";
                      actionValue = "${folderName}/Notifications/myumbc";
                    }
                    {
                      action = "JunkScore";
                      actionValue = "0";
                    }
                  ]
                )
                (multiAction
                  {
                    name = "RT Ticket Notifications";
                    enabled = true;
                    type = filterTypes "InboxRule" "Manual";
                    action = "Move to folder";
                    actionValue = "${folderName}/Notifications/RT";
                    condition = "OR (from,contains,@rt.umbc.edu)";
                  }
                  [
                    {
                      action = "Move to folder";
                      actionValue = "${folderName}/Notifications/RT";
                    }
                    {
                      action = "JunkScore";
                      actionValue = "0";
                    }
                  ]
                )
                {
                  name = "OSS Security Apache Bullshit";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  condition = "AND (all addresses,contains,oss-security@lists.openwall.com) AND (subject,contains,Apache)";
                  action = "Mark read";
                }
                {
                  name = "Bacula Reports";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  condition = "OR (subject,contains,Bacula Report -) OR (subject,contains,Logwatch for)";
                  action = "Move to folder";
                  actionValue = "${folderName}/Cron";
                }
                {
                  name = "Alertmanager";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  condition = "OR (from,contains,alertmanager@cs.umbc.edu)";
                  action = "Move to folder";
                  actionValue = "${folderName}/Notifications";
                }
                {
                  name = "ClamAV";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  condition = "OR (from,contains,clamav@mail.cs.umbc.edu)";
                  action = "Move to folder";
                  actionValue = "${folderName}/Cron";
                }
                {
                  name = "Wordpress Updates";
                  enabled = true;
                  type = filterTypes "InboxRule" "Manual";
                  condition = "OR (subject,contains,Some plugins have failed to update) OR (subject,contains,Your site has updated to WordPress) OR (subject,contains,Some plugins were automatically updated)";
                  action = "Move to folder";
                  actionValue = "${folderName}/Cron";
                }
                (multiAction
                  {
                    name = "OSS Security";
                    enabled = true;
                    type = filterTypes "InboxRule" "Manual";
                    condition = "OR (all addresses,contains,oss-security@lists.openwall.com)";
                  }
                  [
                    {
                      action = "Move to folder";
                      actionValue = "${folderName}/Notifications/OSS Sec";
                    }
                    {
                      action = "JunkScore";
                      actionValue = "0";
                    }
                  ]
                )
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
          directories = {
            "UMBC LDAP" = {
              hostname = "directory.umbc.edu";
              baseDN = "ou=People,dc=umbc,dc=edu";
              settings = id: {
                  "ldap_2.servers.ldap_${id}.maxHits" = 100;
              };
            };
          };
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
          extensions = with nur.repos.rycee.thunderbird-addons; [
            filtaquilla
            # importexportng
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

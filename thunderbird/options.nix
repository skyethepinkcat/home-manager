{
  config,
  lib,
  ...
}:
let
  inherit (lib) types mkOption;
  cfg = config.programs.thunderbird;
in

{
  options.programs.thunderbird.directories = mkOption {
    type = types.listOf (
      types.submodule (submodule_attrs: {
        options = {
          name = mkOption {
            type = types.str;
            description = "User-friendly name of the directory server.";
          };
          default = mkOption {
            type = types.bool;
            default = false;
            description = "Use this LDAP directory server by default. only one default may be set.";
          };
          hostname = mkOption {
            type = types.str;
            description = "Hostname of the directory server.";
          };
          ssl = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use SSL.";
          };
          port = mkOption {
            type = types.int;
            default = if submodule_attrs.config.ssl then 636 else 389;
            description = "The port to connect to.";
          };
          gssapi = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use GSSAPI authentication.";
            example = true;
          };
          baseDN = mkOption {
            type = types.str;
            example = "ou=People,dc=example,dc=edu";
            description = "The base distinguished name to search in.";
          };
          bindDN = mkOption {
            type = types.str;
            description = "The distinguished name of the user account for authentication. See https://docs.ldap.com/ldap-sdk/docs/tool-usages/ldapsearch.html";
            default = "";
          };
          searchFilter = mkOption {
            type = types.str;
            default = "";
            example = "(objectclass=*)";
            description = "An additional search filter for the directory.";
          };
          maxHits = mkOption {
            type = types.int;
            default = 100;
            example = 1000;
            description = "The maximum number of results to return at once";
          };
          uri = mkOption {
            type = types.str;
            internal = true;
            description = "Calculated ldap uri of the server.";
          };
          id = mkOption {
            type = types.str;
            internal = true;
            description = "Unique ID of this server.";
          };
          subtree = mkOption {
            type = types.bool;
            default = true;
            example = false;
            description = "Set to false to use only a single level directory.";
          };
          accounts = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = [ "gmail" ];
            description = "A list of the names of thunderbird accounts to use this. The accounts should be defined in ``config.accounts.email.accounts``.";
          };
        };
        config =
          let
            subcfg = submodule_attrs.config;
          in
          {
            id = builtins.hashString "sha256" subcfg.name;
            uri =
              let
                ssl_char = lib.strings.optionalString subcfg.ssl "s";
                scope_string = if subcfg.subtree then "sub" else "one";
                # Just to make the size of the string more bearable
                inherit (subcfg)
                  hostname
                  port
                  baseDN
                  searchFilter
                  ;
              in
              "ldap${ssl_char}://${hostname}:${toString port}/${baseDN}??${scope_string}?${searchFilter}";
          };
      })
    );
    description = "List of LDAP directory submodules.";
    default = [ ];
  };
  config =
    let
      directory_accounts = lib.unique (builtins.concatMap (d: d.accounts) cfg.directories);
    in
    {
      accounts.email.accounts = lib.genAttrs directory_accounts (account: {
        thunderbird.settings =
          id:
          lib.mergeAttrsList (
            map (directory: {
              "mail.identity.id_${id}.directoryServer" = "ldap_2.servers.${directory.id}";
            }) (builtins.filter (directory: builtins.elem account directory.accounts) cfg.directories)
          );

      });
      programs.thunderbird = {
        settings = lib.mkIf (builtins.length cfg.directories > 0) (
          assert lib.assertMsg (
            builtins.length (builtins.filter (d: d.default) cfg.directories) <= 1
          ) "Only one default LDAP directory may be set!";
          lib.mergeAttrsList (
            map (
              directory:
              {
                "ldap_2.servers.${directory.id}.maxHits" = directory.maxHits;
                "ldap_2.servers.${directory.id}.auth.dn" = directory.bindDN;
                "ldap_2.servers.${directory.id}.saslmech.dn" = lib.strings.optionalString directory.ssl "GSSAPI";
                "ldap_2.servers.${directory.id}.filename" = "ldap.sqlite";
                "ldap_2.servers.${directory.id}.description" = directory.name;
                "ldap_2.servers.${directory.id}.uri" = directory.uri;
              }
              // lib.optionalAttrs directory.default {
                "ldap_2.autoComplete.directoryServer" = "ldap_2.servers.${directory.id}";
                "ldap_2.autoComplete.useDirectory" = true;

              }
            ) cfg.directories
          )
        );

      };
    };
}

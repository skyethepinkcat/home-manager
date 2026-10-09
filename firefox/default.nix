{
  pkgs,
  config,
  lib,
  nur,
  host,
  ...
}:
let
  inherit (lib) mkForce mkIf;
  inherit (pkgs) fetchFirefoxAddon;
in
{
  programs.firefox = {
    configPath = "${config.xdg.configHome}/firefox";
    languagePacks = [
      "en-US"
      "ja"
    ];

    enable = host.hasTags "desktop";
    policies = {
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      # Feature Disabling
      DisablePocket = true;
      DisableTelemetry = true;

      # Access Restrictions
      BlockAboutConfig = false;

      # UI and Behavior
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      # DefaultDownloadDirectory      = "${home}/Downloads";
    };

    profiles.nix = {
      isDefault = true;
      extensions =
        let
          buildAddon =
            {
              name,
              url,
              hash,
              addonId,
            }:
            (fetchFirefoxAddon {
              inherit name url hash;
            }).overrideAttrs
              {
                inherit addonId;
              };
          addons = {
            inherit (nur.repos.rycee.firefox-addons)
              ublock-origin
              privacy-badger
              sponsorblock
              violentmonkey
              sonarr-radarr-lidarr-search
              ;

            tenhou_ui_translator = buildAddon {
              name = "Tenhou English UI";
              url = "https://addons.mozilla.org/firefox/downloads/file/4296344/tenhou_ui_translator-9.4.3.xpi";
              hash = "sha256-WrqyRPlaUyMHiTkacneXn+VfX9cPTxTTbI9ZRq282a4=";
              addonId = "{f6d2b88f-7911-47b4-8a12-af6c380784cc}";
            };

          };
        in
        {
          packages = builtins.attrValues addons;

          force = true;
          settings = {
            "uBlock0@raymondhill.net" = {
              settings.selectedFilterLists = [
                "ublock-filters"
                "ublock-badware"
                "ublock-privacy"
                "ublock-unbreak"
                "ublock-quick-fixes"
              ];
            };
            "${addons.tenhou_ui_translator.addonId}".settings = {
              language = "en";
              tileset = "DEFAULT";
              translation = "DEFAULT";
              toggle = true;
              altTranslation = "DEFAULT,EMA_ENG,ENG";
            };
          };
        };
      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";

        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };
        };

      };
    };
  };
}

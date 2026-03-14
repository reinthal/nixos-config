{
  config,
  pkgs,
  ...
}: {
  # Enable vdirsyncer program (generates config file)
  programs.vdirsyncer = {
    enable = true;
  };

  # Enable vdirsyncer systemd service (runs sync periodically)
  services.vdirsyncer = {
    enable = true;
    frequency = "*:0/15"; # Run every 15 minutes (see systemd.time(7))
    # verbosity = "DEBUG"; # Uncomment for troubleshooting
  };

  # Calendar accounts
  accounts.calendar = {
    basePath = "${config.home.homeDirectory}/.local/share/calendars";

    accounts = {
      # iCloud CalDAV calendar
      icloud = {
        primary = true;
        primaryCollection = "home";

        local = {
          type = "filesystem";
          fileExt = ".ics";
        };

        remote = {
          type = "caldav";
          url = "https://caldav.icloud.com";
          userName = "kog@wlots.st";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."apple/icloud_password".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"]; # Sync all collections discovered from server
          conflictResolution = "remote wins";
        };

        khal = {
          enable = true;
          type = "discover";
        };
      };

      # Proton Mail Bridge CalDAV calendar
      protonmail = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${config.home.homeDirectory}/.local/share/calendars/ProtonMirror";
        };

        remote = {
          type = "caldav";
          url = "http://127.0.0.1:8081";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/bridge_pw".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = [
            [
              "ProtonMirror"
              "q2zVgfHcJ-_us1hjWde6kihJJCqsiI7gAIYLNb5PkdHg7i_ji3oNyMNnDMQhEwPmQBBzokMInDGZNsMSL3bjGw=="
              "ProtonMirror"
            ]
          ];
          conflictResolution = "remote wins";
          userNameCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/username".path}"];
          auth = "basic";
        };

        khal = {
          enable = true;
          type = "discover";
        };
      };

      # iCloud mirror target for ProtonMirror
      icloud_protonmirror = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${config.home.homeDirectory}/.local/share/calendars/ProtonMirror";
        };

        remote = {
          type = "caldav";
          url = "https://caldav.icloud.com";
          userName = "kog@wlots.st";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."apple/icloud_password".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = [
            [
              "ProtonMirror"
              "808c61e1-3fe3-4998-aa29-f334d6270a49"
              "ProtonMirror"
            ]
          ];
          conflictResolution = "local wins";
        };
      };
    };
  };

  # Contact accounts
  accounts.contact = {
    basePath = "${config.home.homeDirectory}/.local/share/contacts";

    accounts = {
      # iCloud CardDAV contacts
      icloud = {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
        };

        remote = {
          type = "carddav";
          url = "https://contacts.icloud.com";
          userName = "kog@wlots.st";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."apple/icloud_password".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"]; # Sync all collections
        };
      };

      # Proton Mail Bridge CardDAV contacts
      protonmail = {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
        };

        remote = {
          type = "carddav";
          url = "http://127.0.0.1:8080";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/bridge_pw".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"];
          userNameCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/username".path}"];
          auth = "basic";
        };
      };
    };
  };
}

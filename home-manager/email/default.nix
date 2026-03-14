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
      protonmmail = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
        };

        remote = {
          type = "caldav";
          url = "https://127.0.0.1:8081";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/bridge_pw".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"];
          conflictResolution = "remote wins";
          userNameCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/username".path}"];
        };

        khal = {
          enable = true;
          type = "discover";
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
      protonmmail = {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
        };

        remote = {
          type = "carddav";
          url = "https://127.0.0.1:8080";
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/bridge_pw".path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"];
          userNameCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets."protonmail/username".path}"];
        };
      };
    };
  };
}

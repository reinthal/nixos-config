{
  config,
  pkgs,
  ...
}: {
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

        local = {
          type = "filesystem";
          fileExt = ".ics";
        };

        remote = {
          type = "caldav";
          url = "https://caldav.icloud.com";
          userNameCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets.apple.icloud_username.path}"];
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets.apple.icloud_password.path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"]; # Sync all collections discovered from server
          conflictResolution = "remote wins"; # Uncomment if needed
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
          url = "https://carddav.icloud.com";
          userNameCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets.apple.icloud_username.path}"];
          passwordCommand = ["${pkgs.coreutils}/bin/cat" "${config.sops.secrets.apple.icloud_password.path}"];
        };

        vdirsyncer = {
          enable = true;
          collections = ["from a" "from b"]; # Sync all collections
        };
      };
    };
  };
}

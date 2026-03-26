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

      # Proton Mail subscription calendar (ICS)
      protonmail = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${config.home.homeDirectory}/.local/share/calendars/ProtonMirror";
        };

        remote = {
          type = "http";
          url = "https://calendar.proton.me/api/calendar/v1/url/RXshcc0AgOWV3fruLLD95HoA8YzQuUD7muNPq9DRaQC7kOM0AWymFpWXtQIgksMXqwt8GFzWwA982umokM3TOw==/calendar.ics?CacheKey=-eoPYJakgSs-CjyHe9x0vA%3D%3D";
        };

        vdirsyncer = {
          enable = true;
          collections = null;
          conflictResolution = "remote wins";
        };

        khal = {
          enable = true;
          type = "discover";
        };
      };

      # Google Calendar (OAuth)
      google = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${config.home.homeDirectory}/.local/share/calendars/Google";
        };

        remote = {
          type = "google_calendar";
        };

        vdirsyncer = {
          enable = true;
          tokenFile = "${config.home.homeDirectory}/.config/vdirsyncer/google-calendar-token";
          clientIdCommand = [
            "${pkgs.coreutils}/bin/printf"
            "%s"
            "683189906705-akr3qsd7n34t4drc0qf02tii6vpk518h.apps.googleusercontent.com"
          ];
          clientSecretCommand = [
            "${pkgs.coreutils}/bin/cat"
            "${config.sops.secrets."gcalendar/client_secret".path}"
          ];
          collections = ["from a" "from b"]; # Sync all collections discovered from server
          conflictResolution = "remote wins";
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

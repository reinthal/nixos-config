{
  config,
  pkgs,
  ...
}: let
  calBase = "${config.home.homeDirectory}/.local/share/calendars";
  statusBase = "${config.home.homeDirectory}/.local/share/vdirsyncer/status";

  # Separate vdirsyncer config for cross-provider sync pairs
  crossSyncConfig = pkgs.writeText "vdirsyncer-cross-sync" ''
    [general]
    status_path = "${statusBase}"

    [pair google_to_icloud_sekten]
    a = "google_sekten_local"
    b = "icloud_sekten_local"
    collections = null
    conflict_resolution = "a wins"

    [storage google_sekten_local]
    type = "filesystem"
    path = "${calBase}/Google/f5s78enb50i5h34qor4nak64v0@group.calendar.google.com"
    fileext = ".ics"
    read_only = true

    [storage icloud_sekten_local]
    type = "filesystem"
    path = "${calBase}/icloud/7ff0cadc-7dba-4de8-a2d2-df9e41b0e545"
    fileext = ".ics"
  '';
in {
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
    basePath = calBase;

    accounts = {
      # === iCloud vdirsyncer account (syncs all collections, khal disabled) ===
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
          collections = ["from a" "from b"];
          conflictResolution = "remote wins";
        };

        khal.enable = false;
      };

      # === iCloud khal-only accounts (human-readable names) ===
      icloud-alex-plugg = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#1abc9c";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/icloud/0377499b-caab-4580-98f5-9b2db1d146bb";
        };
      };

      icloud-alex = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#3498db";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/icloud/home";
        };
      };

      icloud-denise = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#e74c3c";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/icloud/612ed258cdb684182a4cc6a93326bdfae464fc49dc033654686282329408116a";
        };
      };

      icloud-orginal-f = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#9b59b6";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/icloud/56f5813094d234d93b4e4be92ff73c0d6751f8bf4b7e7728cb9c2aaba6bf4260";
        };
      };

      icloud-staddagar = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#f39c12";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/icloud/8A40F4CE-2CC9-4F5E-947E-DCB33AD93DC0";
        };
      };

      icloud-sekten-wlots = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#e67e22";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/icloud/7ff0cadc-7dba-4de8-a2d2-df9e41b0e545";
        };
      };

      # === Google vdirsyncer account (syncs all collections, khal disabled) ===
      google = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/Google";
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
          collections = ["from a" "from b"];
          conflictResolution = "remote wins";
        };

        khal.enable = false;
      };

      # === Google khal-only accounts (human-readable names) ===
      google-main = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#2ecc71";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/Google/alexander.reinthal@gmail.com";
        };
      };

      google-holidays = {
        khal = {
          enable = true;
          type = "calendar";
          readOnly = true;
          color = "#95a5a6";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/Google/cln2qpr25ppnepb4d5pmg8r8dtm6ip31f506esjfelo2sthecdgmopbechgn4bj7dtnmer355phmur8@virtual";
        };
      };

      google-sekten = {
        khal = {
          enable = true;
          type = "calendar";
          color = "#e67e22";
        };
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/Google/f5s78enb50i5h34qor4nak64v0@group.calendar.google.com";
        };
      };

      # === Proton Mail calendar (ICS subscription) ===
      protonmail = {
        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${calBase}/ProtonMirror";
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
          type = "calendar";
          readOnly = true;
          color = "#8e44ad";
        };
      };
    };
  };

  # Cross-provider sync: Google Sekten -> iCloud Sekten/WLOTS (one-way)
  systemd.user.services.vdirsyncer-cross-sync = {
    Unit = {
      Description = "Sync Google Sekten calendar to iCloud Sekten/WLOTS";
      After = ["vdirsyncer.service"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "vdirsyncer-cross-sync" ''
        ${pkgs.vdirsyncer}/bin/vdirsyncer -c ${crossSyncConfig} discover
        ${pkgs.vdirsyncer}/bin/vdirsyncer -c ${crossSyncConfig} sync
      ''}";
    };
  };

  systemd.user.timers.vdirsyncer-cross-sync = {
    Unit = {
      Description = "Run cross-provider calendar sync every 15 minutes";
    };
    Timer = {
      OnCalendar = "*:0/15";
      Persistent = true;
      RandomizedDelaySec = 60;
    };
    Install = {
      WantedBy = ["timers.target"];
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
          collections = ["from a" "from b"];
        };
      };
    };
  };
}

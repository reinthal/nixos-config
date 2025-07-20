{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.services.meilisearch;
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.services.meilisearch = {
    enable = mkEnableOption "Meilisearch search engine";

    package = mkOption {
      type = types.package;
      default = pkgs.meilisearch;
      defaultText = lib.literalExpression "pkgs.meilisearch";
      description = "The Meilisearch package to use.";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "The IP address to bind to.";
    };

    listenPort = mkOption {
      type = types.port;
      default = 7700;
      description = "The port to bind to.";
    };

    environment = mkOption {
      type = types.enum ["development" "production"];
      default = "development";
      description = "The environment in which to run Meilisearch.";
    };

    dbPath = mkOption {
      type = types.str;
      default = "/var/lib/meilisearch";
      description = "Path to the Meilisearch database directory.";
    };

    noAnalytics = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to disable analytics.";
    };

    logLevel = mkOption {
      type = types.enum ["ERROR" "WARN" "INFO" "DEBUG" "TRACE"];
      default = "INFO";
      description = "The log level for Meilisearch.";
    };

    maxIndexSize = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "100 MiB";
      description = "Maximum size of the index.";
    };

    payloadSizeLimit = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "100 MiB";
      description = "Maximum size of accepted payloads.";
    };

    masterKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing the master key for authentication.";
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra environment variables to pass to Meilisearch.";
    };
  };

  config = mkIf cfg.enable {
    users.users.meilisearch = {
      isSystemUser = true;
      group = "meilisearch";
      description = "Meilisearch daemon user";
    };

    users.groups.meilisearch = {};

    systemd.tmpfiles.rules = [
      "d '${cfg.dbPath}' 0750 meilisearch meilisearch -"
    ];

    systemd.services.meilisearch = {
      description = "Meilisearch search engine";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment =
        {
          MEILI_DB_PATH = cfg.dbPath;
          MEILI_HTTP_ADDR = "${cfg.listenAddress}:${toString cfg.listenPort}";
          MEILI_ENV = cfg.environment;
          MEILI_LOG_LEVEL = cfg.logLevel;
          MEILI_NO_ANALYTICS = lib.boolToString cfg.noAnalytics;
        }
        // lib.optionalAttrs (cfg.maxIndexSize != null) {
          MEILI_MAX_INDEX_SIZE = cfg.maxIndexSize;
        }
        // lib.optionalAttrs (cfg.payloadSizeLimit != null) {
          MEILI_HTTP_PAYLOAD_SIZE_LIMIT = cfg.payloadSizeLimit;
        }
        // cfg.extraEnvironment;

      serviceConfig = {
        Type = "simple";
        User = "meilisearch";
        Group = "meilisearch";
        ExecStart = "${cfg.package}/bin/meilisearch";
        Restart = "on-failure";
        RestartSec = 5;

        # Security settings
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;

        # Allow access to database directory
        ReadWritePaths = [cfg.dbPath];
      };

      preStart = lib.optionalString (cfg.masterKeyFile != null) ''
        export MEILI_MASTER_KEY="$(cat ${cfg.masterKeyFile})"
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.listenAddress != "127.0.0.1") [cfg.listenPort];
  };
}


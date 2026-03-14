{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.services.ferroxide;
  inherit (lib) mkEnableOption mkOption mkIf types;

  defaultFirewallPorts = mode:
    if mode == "serve"
    then [1025 1143 8080 8081]
    else if mode == "smtp"
    then [1025]
    else if mode == "imap"
    then [1143]
    else if mode == "carddav"
    then [8080]
    else if mode == "caldav"
    then [8081]
    else [];

  execArgs = lib.escapeShellArgs cfg.extraArgs;
in {
  options.services.ferroxide = {
    enable = mkEnableOption "Third-party ProtonMail bridge with CalDAV support";

    package = mkOption {
      type = types.package;
      default = pkgs.local-pkgs.ferroxide;
      defaultText = lib.literalExpression "pkgs.local-pkgs.ferroxide";
      description = "The ferroxide package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "ferroxide";
      description = "User account under which ferroxide runs.";
    };

    group = mkOption {
      type = types.str;
      default = "ferroxide";
      description = "Group under which ferroxide runs.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/ferroxide";
      description = "Directory used as the HOME/working directory for ferroxide.";
    };

    mode = mkOption {
      type = types.enum ["serve" "smtp" "imap" "carddav" "caldav"];
      default = "serve";
      description = "ferroxide subcommand to run as a daemon.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra CLI arguments to pass to ferroxide.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra environment variables to pass to ferroxide.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the firewall for ferroxide.";
    };

    firewallPorts = mkOption {
      type = types.listOf types.port;
      default = defaultFirewallPorts cfg.mode;
      description = "Ports to open in the firewall when openFirewall is enabled.";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      description = "ferroxide daemon user";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.ferroxide = {
      description = "ferroxide ProtonMail bridge";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment =
        {
          HOME = cfg.dataDir;
        }
        // cfg.environment;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/ferroxide ${cfg.mode} ${execArgs}";
        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;

        ReadWritePaths = [cfg.dataDir];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall cfg.firewallPorts;
  };
}

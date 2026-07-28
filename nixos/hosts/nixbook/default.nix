{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common.nix
    # apple-silicon hardware support
    inputs.apple-silicon.nixosModules.apple-silicon-support

    # steam via muvm (Asahi)
    inputs.steam-asahi.nixosModules.default

    ../../features/apps/podman.nix
    ../../features/desktop
    ../../features/sops.nix
    ../../features/nas.nix
    ../../features/apps/wlots-client.nix
    ../../features/cli
    ../../features/apps/syncthing.nix
    (import ../../features/networking "nixbook")
    # enable various features
    ../../features/sound.nix
    ../../features/bluetooth.nix

    # font config
    ../../features/hidpi.nix
    # modules
    outputs.nixosModules.dual-function-keys
    outputs.nixosModules.v4l2-loopback

    # key mappings
    ../../features/key-mappings/caps-to-ctrl-esc.nix
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.efi.canTouchEfiVariables = false;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [1716];
  };

  hardware = {
    asahi = {
      enable = true;
      peripheralFirmwareDirectory = ./firmware;
      setupAsahiSound = true;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libGL
        mesa
      ];
    };
  };

  sops.secrets.borg_passphrase = {
    owner = config.users.users.kog.name;
  };

  services = {
    borgbackup.jobs = let
      common-excludes = [
        # Largest cache dirs
        ".hf"
        ".cache"
        "*/cache2" # firefox
        "*/Cache"
        ".config/Slack/logs"
        ".config/Code/CachedData"
        ".container-diff"
        ".npm/_cacache"
        # Work related dirs
        "*/node_modules"
        "*/bower_components"
        "*/_build"
        "*/.tox"
        "*/venv"
        "*/.venv"
        "*/.devenv"
        "Downloads"
      ];
      work-dirs = [
        "/home/kog/repos"
      ];
      basicBorgJob = name: {
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.sops.secrets.borg_passphrase.path}";
        };
        environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/kog/.ssh/id_ed25519";
        extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
        repo = "ssh://borgwarehouse@borg.nas.reinthal.me:2222/./${name}";
        compression = "zstd,1";
        startAt = "daily";
        user = "kog";
      };
    in {
      home-kog =
        basicBorgJob "a7b0609d"
        // rec {
          paths = "/home/kog";
          exclude = work-dirs ++ map (x: paths + "/" + x) common-excludes;
        };
    };

    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    automatic-timezoned.enable = true;
    upower.enable = true;
    # Printer  and printer discovery
    printing.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=7day
    '';
    # enable if printer issues
    #avahi = {
    #enable = true;
    #nssmdns4 = true;
    # openFirewall = true;
    #};
    actkbd = {
      enable = true;
      bindings = [
        {
          keys = [225];
          events = ["key"];
          command = "/run/current-system/sw/bin/light -A 10";
        }
        {
          keys = [224];
          events = ["key"];
          command = "/run/current-system/sw/bin/light -U 10";
        }
      ];
    };
    tailscale.enable = true;
  };
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
     ${pkgs.gnupg}/bin/gpg-connect-agent /bye
     export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';
  programs = {
    steam-asahi = {
      enable = true;
    };
    ssh.startAgent = false;
    zsh.enable = true;
    dconf.enable = true;
    nix-ld.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
  time.timeZone = lib.mkForce null;
  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = "25.05";
      isNvidia = false;
      secretsFile = ../../../secrets/shhh.yaml;
    };
    users = {
      kog = import ../../../home-manager;
    };
  };

  system.stateVersion = "25.11";
}

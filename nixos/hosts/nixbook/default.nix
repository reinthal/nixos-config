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

    ../../features/apps/podman.nix
    ../../features/coms
    ../../features/desktop
    ../../features/sops.nix
    ../../features/nas.nix
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
    outputs.nixosModules.ferroxide

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

  services = {
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
    ferroxide = {
      enable = true;
      mode = "serve";
    };
  };
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
     ${pkgs.gnupg}/bin/gpg-connect-agent /bye
     export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';
  programs = {
    ssh.startAgent = false;
    zsh.enable = true;
    dconf.enable = true;
    nix-ld.enable = true;
    light.enable = true;
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

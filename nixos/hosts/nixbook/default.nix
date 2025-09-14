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
  boot.loader.efi.canTouchEfiVariables = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [1716];
  };

  # enable audio
  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    setupAsahiSound = true;
  };

  # backlight control

  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
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
    ssh.startAgent = false;
    zsh.enable = true;
    dconf.enable = true;
    nix-ld.enable = true;
    light.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry.curses;
    };
  };

  time.timeZone = "Europe/Stockholm";

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = "25.05";
    };
    users = {
      kog = import ../../../home-manager;
    };
  };

  environment.systemPackages = with pkgs; [
    pinentry.curses
  ];
  system.stateVersion = "25.11";
}

{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../minimal.nix
    outputs.nixosModules.nvidia
    ../../features/nas.nix
    ../../features/sops.nix
    ../../features/cli/default.nix
    ../../features/apps/jellyfin.nix
    ../../features/apps/qbittorrent.nix
    ../../features/apps/podman.nix
    ../../features/apps/navidrome.nix
    ../../features/apps/pinchflat.nix
    inputs.home-manager.nixosModules.default
  ];
  fileSystems."/mnt/photos" = {
    device = "nas.reinthal.me:/mnt/tonberry/photos";
    fsType = "nfs";
    options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30"];
  };
  nvidia.enable = true;

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = "24.11";
    };
    users = {
      kog = import ../../../home-manager/flix.nix;
    };
  };

  # Bootloader.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-aa17dffc-bb20-4e3e-95c1-259a5b6b4d43".device = "/dev/disk/by-uuid/aa17dffc-bb20-4e3e-95c1-259a5b6b4d43";
  networking = {
    hostName = "flix";
    extraHosts = ''
      10.22.21.10 nas.reinthal.me
    '';
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [2283 8888];
    };
  };
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  time.timeZone = "Europe/Stockholm";
  system.stateVersion = "24.11"; # Did you read the comment?
}

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
  hardware.nvidia.package = lib.mkForce (config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "580.105.08";
    sha256_64bit = "sha256:0x9l55imfqhpin6c5j3204fzlyc4snfsdkq4vmsfpwvjhqcfiinr";
    openSha256 = "sha256:013kk58lm9w82l1vl43jxs4plvxysb096b5cmcwbqhm1fjvqqs8l";
    settingsSha256 = "sha256:1dlc52md0m7d193xvfbrdiwz4v9792zgj44pnw6nwsipalxxdz32";
    persistencedSha256 = "sha256:1qmf3f3zrjlzfdfzxrlmzisg0pi1fnpyw1qc1ak4i32ldhl2j7xa";
  });

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
  boot.kernelPackages = pkgs.linuxPackages_6_12;
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

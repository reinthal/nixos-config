{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../features/cli/default.nix
    ../../features/apps/qbittorrent.nix
    ../../features/s3fs
    ../../features/sops.nix
    inputs.home-manager.nixosModules.default
  ];
  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {inherit pkgs inputs outputs;};
    users = {
      kog = import ../../../home-manager/seed.nix;
    };
  };
  nixpkgs.config.allowUnfree = true;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = "seed";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  system.stateVersion = "24.05";
}

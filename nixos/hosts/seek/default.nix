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
    ../../minimal.nix
    inputs.home-manager.nixosModules.default
  ];

  # Docker daemon
  virtualisation.docker.enable = true;
  users.users.kog.extraGroups = ["docker"];

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {inherit pkgs inputs outputs;};
    users = {
      kog = import ../../../home-manager/seek.nix;
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = "seek";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  system.stateVersion = "26.05";
}

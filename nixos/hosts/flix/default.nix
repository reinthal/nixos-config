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
    ../../common.nix
    ../../features/nas.nix
    ../../features/sops.nix
    ../../features/nvidia.nix
    ../../features/cli/default.nix

    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {inherit pkgs inputs outputs;};
    users = {
      kog = import ../../../home-manager/flix.nix;
    };
  };

  # Bootloader.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-aa17dffc-bb20-4e3e-95c1-259a5b6b4d43".device = "/dev/disk/by-uuid/aa17dffc-bb20-4e3e-95c1-259a5b6b4d43";
  networking.hostName = "flix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gnome-remote-desktop
    pinentry.curses
  ];

  programs.zsh.enable = true;

  time.timeZone = "Europe/Stockholm";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [];
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

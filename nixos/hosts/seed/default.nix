{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = "seed";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  time.timeZone = "Europe/Amsterdam";
  users.users.kog = {
    isNormalUser = true;
    initialPassword = "the world is a beautiful cat";
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      neovim
    ];
  };

  services.openssh.enable = true;
  system.stateVersion = "24.05";
}

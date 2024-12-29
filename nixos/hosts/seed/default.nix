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

    # Import the S3FS configuration for "music" bucket
    (import ../../features/s3fs/default.nix {
      inherit pkgs lib;
      bucket = "music";
      keyfile = config.sops.secrets."hetzner/music".path;
      mount = "/mnt/media/torrent";
    })

    ../../features/sops.nix
    inputs.home-manager.nixosModules.default
  ];
  services.tailscale.enable = true;
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

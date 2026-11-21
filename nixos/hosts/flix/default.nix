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
    inputs.home-manager.nixosModules.default
  ];
  fileSystems."/mnt/photos" = {
    device = "nas.reinthal.me:/mnt/tonberry/photos";
    fsType = "nfs";
    options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30"];
  };
  nvidia.enable = true;
  # GTX 1080 Ti (Pascal): NVIDIA dropped Pascal after the 580 branch, so stay
  # on legacy_580 rather than the module default (nvidiaPackages.stable).
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.legacy_580;

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
  # LTS rather than _latest: the 580 legacy driver only gets maintenance
  # updates and can lag new kernels, which would break the daily auto-update.
  boot.kernelPackages = pkgs.linuxPackages_6_18;
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
  # Automatic updates, same model as framebook: daily rebuild from the
  # root-owned /etc/nixos-config checkout (features/deploy-checkout.nix, via
  # minimal.nix), which only advances over signed commits on origin/flaked.
  # update-flake.yml builds flix and pushes it to B2 before committing a lock
  # bump, so this substitutes instead of compiling. Never reboots on its own:
  # root is LUKS-encrypted and needs the passphrase at boot, so kernel/driver
  # updates take effect at the next manual reboot.
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    randomizedDelaySec = "45min";
    persistent = true;
    allowReboot = false;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  time.timeZone = "Europe/Stockholm";
  system.stateVersion = "24.11"; # Did you read the comment?
}

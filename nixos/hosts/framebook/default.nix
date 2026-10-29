# framebook - Framework laptop (x86_64, Intel Core Ultra)
#
# Two desktop sessions are available and picked at login in the ReGreet
# greeter: "hyprland" (primary, configured by home-manager) and "gnome".
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common.nix
    ../../features/apps/podman.nix
    # Hyprland + the ReGreet greeter (greetd)
    ../../features/desktop
    # GNOME registered as a second session in that same greeter
    ../../features/gnome-desktop
    ../../features/sops.nix
    ../../features/cli
    (import ../../features/networking "framebook")
    ../../features/sound.nix
    ../../features/bluetooth.nix

    # modules
    outputs.nixosModules.dual-function-keys

    # key mappings
    ../../features/key-mappings/caps-to-ctrl-esc.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  hardware.graphics.enable = true;

  # Preselected session in ReGreet; the dropdown also offers "gnome".
  services.displayManager.defaultSession = "hyprland";

  services = {
    # Framework ships firmware updates through LVFS.
    fwupd.enable = true;
    upower.enable = true;
    automatic-timezoned.enable = true;
    printing.enable = true;
    journald.settings.Journal = {
      SystemMaxUse = "500M";
      MaxRetentionSec = "7day";
    };
  };
  time.timeZone = lib.mkForce null;

  programs = {
    firefox.enable = true;
    zsh.enable = true;
    nix-ld.enable = true;
  };

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

  system.stateVersion = "26.05"; # Did you read the comment?
}

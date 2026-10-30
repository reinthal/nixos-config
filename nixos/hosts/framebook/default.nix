# framebook - Framework laptop (x86_64, Intel Core Ultra)
#
# Two desktop sessions are available and picked at login in the ReGreet
# greeter: "hyprland" (primary, configured by home-manager) and "gnome".
#
# LUKS: unlocked with either YubiKey (FIDO2, PIN + touch). One-time setup,
# with the current passphrase still in place:
#
#   DEV=/dev/disk/by-uuid/e46d7c02-531e-425e-9c8a-e7230c3bf628
#   sudo systemd-cryptenroll $DEV --fido2-device=auto \
#     --fido2-with-client-pin=yes --fido2-with-user-presence=yes   # key 1, then key 2
#   sudo systemd-cryptenroll $DEV --recovery-key   # write down -> cold storage
#   # reboot and test: key 1, key 2, and the recovery key (no key plugged in:
#   # the passphrase prompt appears after the token timeout)
#   sudo systemd-cryptenroll $DEV --wipe-slot=password
#   sudo cryptsetup luksHeaderBackup $DEV --header-backup-file luks-header.img
#   # header backup -> cold storage, taken AFTER the password slot is gone
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
    (import ../../features/networking {
      hostname = "framebook";
      wifiBackend = "wpa_supplicant";
    })
    ../../features/sound.nix
    ../../features/bluetooth.nix
    # lanzaboote (signed UKIs); see the enrollment steps in the file
    ../../features/secure-boot.nix
    ../../features/fingerprint.nix
    # least-privilege: sudo (wheel-only), nix-daemon (wheel-only), no root login
    ../../features/hardening.nix

    # modules
    outputs.nixosModules.dual-function-keys

    # key mappings
    ../../features/key-mappings/caps-to-ctrl-esc.nix
  ];

  # systemd-boot settings; the installer itself is lanzaboote (secure-boot.nix).
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

  # Automatic updates: weekly rebuild from the flake pushed to GitHub. It applies
  # whatever is committed (including the pinned flake.lock) and never runs
  # `nix flake update` itself, so it can't auto-switch onto a broken pinned
  # input — new versions land only when you update + commit + push. The host is
  # picked by hostname (framebook). fwupd (above) covers firmware separately.
  system.autoUpgrade = {
    enable = true;
    flake = "github:reinthal/nixos-config";
    dates = "daily";
    randomizedDelaySec = "45min";
    persistent = true; # catch up if the laptop was off at the scheduled time
    allowReboot = false; # kernel/initrd updates apply at the next manual reboot
  };

  hardware.graphics.enable = true;

  # Preselected session in ReGreet; the dropdown also offers "gnome".
  services.displayManager.defaultSession = "hyprland";

  services = {
    # YubiKeys: OpenPGP card (pcscd) for gpg, FIDO2 for LUKS.
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization pkgs.libfido2];
    # gpg-agent is the only ssh agent (home-manager/gpg/agent.nix). GNOME's
    # gcr agent would otherwise claim SSH_AUTH_SOCK in both sessions.
    gnome.gcr-ssh-agent.enable = false;
    # Framework ships firmware updates through LVFS.
    fwupd.enable = true;
    upower.enable = true;
    # On AC, closing the lid locks the session but keeps the machine awake so
    # the overnight nixos-upgrade timer (system.autoUpgrade, below) can run. On
    # battery the lid still suspends (services.logind.lidSwitch default). The
    # idle-suspend path (hypridle, home-manager) is AC-aware the same way.
    logind.lidSwitchExternalPower = "lock";
    # Pinned to Europe/Stockholm below. automatic-timezoned (geoclue) never
    # registered a client and failed every run, leaving the clock on UTC; all
    # of Sweden is one zone anyway. Flip back to true + time.timeZone = null to
    # retry location-based tz (e.g. if this laptop starts travelling).
    automatic-timezoned.enable = false;
    printing.enable = true;
    journald.settings.Journal = {
      SystemMaxUse = "500M";
      MaxRetentionSec = "7day";
    };
  };
  time.timeZone = "Europe/Stockholm";

  programs = {
    # Keyring browser for the secrets apps keep in gnome-keyring.
    seahorse.enable = true;
    # Installs hyprlock and its PAM service (fprint config: fingerprint.nix).
    hyprlock.enable = true;
    ssh.startAgent = false;
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
      kog = import ../../../home-manager/framebook.nix;
    };
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}

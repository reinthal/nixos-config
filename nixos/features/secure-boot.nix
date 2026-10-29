# Secure Boot via lanzaboote: systemd-boot + signed UKIs.
# https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/
#
# Keys are created by hand, and enrolling them in firmware is a manual step
# too. Unsigned images are never installed, so a build fails loudly until
# the keys exist:
#
#   1. sudo sbctl create-keys            # -> /var/lib/sbctl
#   2. switch to this config;  sudo sbctl verify  (all *.efi signed)
#   3. firmware: reboot into BIOS, Secure Boot -> erase keys / Setup Mode
#   4. sudo sbctl enroll-keys --microsoft
#      (--microsoft keeps MS keys so fwupd capsules / option ROMs still boot)
#   5. reboot;  bootctl status  -> "Secure Boot: enabled (user)"
#   6. firmware: set a supervisor (BIOS) password
#
# Back up /var/lib/sbctl (encrypted!) to cold storage next to the LUKS
# recovery key; without it a firmware reset means re-enrolling.
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  # lanzaboote replaces the systemd-boot installer.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  # No kernel-cmdline editing in the boot menu (UKI cmdlines are signed anyway).
  boot.loader.systemd-boot.editor = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [pkgs.sbctl];
}

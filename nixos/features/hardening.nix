# Least-privilege hardening: shrink the privileged surface around sudo, the
# nix daemon, and root.
#
# Imported per-host (currently only framebook) rather than baked into the
# baseline on purpose: build/CI and server hosts may legitimately need sudo for
# non-wheel users, nix-daemon access from automation, or root over SSH.
{lib, ...}: {
  # Only wheel members may invoke sudo at all; the sudo binary is inaccessible
  # to everyone else. (Asserts there are no sudo rules for non-wheel users.)
  security.sudo.execWheelOnly = true;

  # Only wheel may connect to the privileged nix-daemon as a build client. By
  # default ANY local user can submit derivations to the daemon, which is a
  # genuine privilege boundary and attack surface. root is always permitted.
  nix.settings.allowed-users = ["@wheel"];

  # No direct root login: force all privilege through sudo (per-user, audited).
  # Root already has no password (NixOS default); this makes it explicit and
  # locks root for local login/su. Recovery, if ever needed, is via booting an
  # older generation or a live USB (Secure Boot is toggleable in firmware with
  # the supervisor password).
  users.users.root.hashedPassword = "!";

  # This laptop has no reason to listen for inbound SSH. minimal.nix enables the
  # server for every host (key-only); turn it off here. With no sshd running,
  # root-over-SSH is moot and the inbound attack surface is gone entirely.
  services.openssh.enable = lib.mkForce false;
}

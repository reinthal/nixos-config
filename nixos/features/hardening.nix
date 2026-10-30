{lib, ...}: {
  security.sudo.execWheelOnly = true;
  nix.settings.allowed-users = ["@wheel"];
}

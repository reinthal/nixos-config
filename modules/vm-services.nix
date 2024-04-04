{ config, pkgs, ... }:

{
  services = {
    openssh = {
  enable = true;
  # require public key authentication for better security
  settings.PasswordAuthentication = false;
  settings.KbdInteractiveAuthentication = false;
    };
    qemuGuest.enable = true;
  };
}

{ config, pkgs, ... }:

{
  services = {
    openssh = {
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      enable = true;
    };
    qemuGuest.enable = true;
  };
}

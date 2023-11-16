{ config, pkgs, ... }:
{
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
  };
  settings = {
    ContactInfo = "hot.taco.relay@protonmail.com";
    Nickname = "Hot Taco Relay Administrator";
    ORPort = 9001;
    ControlPort = 9051;
    BandWidthRate = "1 MBytes";
  };
};
}

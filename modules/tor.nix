{ config, pkgs, ... }:
{
    services.tor.enable = true; 
    environment.etc."tor/torrc".text = pkgs.lib.mkForce ''
Nickname      HotTacoRelay 
ContactInfo   hot.taco.relay@protonmail.com
ORPort        443
ExitRelay     0
SocksPort     0
Log notice    syslog
DataDirectory /var/lib/tor
User          tor
''; 
}

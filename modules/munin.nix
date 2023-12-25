{ config, pkgs, ... }:
{
  
  services = {
    munin-node.enable = true;
    munin-node.extraConfig = ''
        cidr_allow ^10\.13\.36\.0/24$
    '';
    munin-cron.enable = true;
  };
 
}

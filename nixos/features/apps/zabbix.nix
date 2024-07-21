{ config, pkgs, ... }:
{
  
  services = {
    zabbixAgent.enable = true;
    zabbixAgent.server = "zabbix.reinthal.me";
    zabbixAgent.settings = {
      DebugLevel = 4;
      HostMetadata="Linux";
    };
  };
}

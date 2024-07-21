hostname:
{
    networking = {
    hostName = hostname;
    firewall.checkReversePath = false;
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      wifi.backend = "iwd";
    };
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
  };
}   
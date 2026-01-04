hostname: {
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };
  networking = {
    enableIPv6 = false;
    hostName = hostname;
    firewall.checkReversePath = false;
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      wifi.backend = "iwd";
      connectionConfig = {
        "ipv6.method" = "disabled";
      };
    };
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = false;
    };
  };
}

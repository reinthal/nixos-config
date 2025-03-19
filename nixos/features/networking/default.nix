hostname: {
  networking = {
    hostName = hostname;
    firewall.checkReversePath = false;
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      wifi.backend = "iwd";
    };
    # sinkhole mozilla telemetry
    extraHosts = ''
      127.0.0.1 incoming.telemetry.mozilla.org
    '';
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
  };
}


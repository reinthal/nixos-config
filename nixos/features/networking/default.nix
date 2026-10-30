# Shared networking for laptops. `wifiBackend` selects NetworkManager's wifi
# driver: "iwd" (default) or "wpa_supplicant". framebook overrides to
# wpa_supplicant because its Intel BE211 (Wi-Fi 7) card associates unreliably
# under iwd (repeated `net.connman.iwd.Failed` / `connect-failed status 1`);
# see docs/framebook-issues.md.
{
  hostname,
  wifiBackend ? "iwd",
}: {lib, ...}: {
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
  };
  networking = {
    enableIPv6 = false;
    hostName = hostname;
    firewall.checkReversePath = false;
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      wifi.backend = wifiBackend;
      connectionConfig = {
        "ipv6.method" = "disabled";
      };
    };
    # NetworkManager drives wpa_supplicant itself when that backend is picked,
    # so only stand up iwd when it is the selected backend.
    wireless.iwd = lib.mkIf (wifiBackend == "iwd") {
      enable = true;
      settings.General.EnableNetworkConfiguration = false;
    };
  };
}

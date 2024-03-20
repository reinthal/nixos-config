{ pkgs, config, ... }: # to uncomment section with lib.mkForce add lib here
{
  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;     
      # Enable the KDE Plasma Desktop Environment.
      desktopManager.plasma5.enable = true;

#      displayManager = {
#        job.execCmd = lib.mkForce "exec /run/current-system/sw/bin/sddm";
#        sddm.enable = lib.mkDefault true;
#        defaultSession = "plasmawayland";
#      };
    };
  };
  
  # programs
  programs = {
    partition-manager.enable = true;
    kdeconnect.enable = true;
  };

    networking.firewall = {
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };

  environment.systemPackages = with pkgs; [
  firefox
  
  libsForQt5.plasma-pa    
  libsForQt5.plasma-browser-integration
  ];
}

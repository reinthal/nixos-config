{ config, pkgs, ... }:

{

    # Enable networking
	  networking.networkmanager.enable = true;

	  # Docker
	  virtualisation.docker.enable = true;
	  virtualisation.docker.rootless = {
	    enable = true;
	    setSocketVariable = true;
	  };

  services = {
    openssh.enable = true;
    qemuGuest.enable = true;
  };
}
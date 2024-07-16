{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
                ../../modules/users.nix
		../../modules/locales.nix
		../../modules/nas-client.nix
		../../modules/vm-services.nix
		../../modules/nice-to-have-packages.nix

  ];
 #         networking = {
#	     hostName = "streamer2"; # Define your hostname.
#	     networkmanager.enable = true;
#	     firewall.enable = false;
#	  };


	  # Set your time zone.
	  time.timeZone = "Europe/Stockholm";

	  # Allow unfree packages
	  nixpkgs.config.allowUnfree = true;

	
	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system = {
             autoUpgrade.enable = true;
             autoUpgrade.allowReboot = true;

            stateVersion = "23.05"; # Did you read the comment?
        };

}

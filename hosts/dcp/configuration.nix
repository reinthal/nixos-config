# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	  imports =
	    [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		../../modules/users.nix
		../../modules/locales.nix
		../../modules/nas-client.nix
                ../../modules/nice-to-have-packages.nix
                ../../modules/vm-services.nix
	    ];

	  # Bootloader.
	  boot.loader.grub.enable = true;
	  boot.loader.grub.device = "/dev/sda";
	  boot.loader.grub.useOSProber = true;

	  networking = {
	     hostName = "dcp"; # Define your hostname.
             extraHosts = 
	    ''
             10.22.22.10 nas.reinthal.me
            '';
	     networkmanager.enable = true;
	     firewall.enable = false;
	  };

	  
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

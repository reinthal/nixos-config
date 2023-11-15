# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	  imports =
	    [ # Include the results of the hardware scan.
	      ./hardware-configuration.nix
	    ];

	  # Bootloader.
	  boot.loader.grub.enable = true;
	  boot.loader.grub.device = "/dev/sda";
	  boot.loader.grub.useOSProber = true;

	  networking.hostName = "nixos"; # Define your hostname.

	  # Enable networking
	  networking.networkmanager.enable = true;
	  # docker yes?
	  virtualisation.docker.enable = true;
	  virtualisation.docker.rootless = {
	    enable = true;
	    setSocketVariable = true;
	  };
	  # Set your time zone.
	  time.timeZone = "Europe/Stockholm";

	  # Select internationalisation properties.
	  i18n.defaultLocale = "en_US.UTF-8";

	  i18n.extraLocaleSettings = {
	    LC_ADDRESS = "sv_SE.UTF-8";
	    LC_IDENTIFICATION = "sv_SE.UTF-8";
	    LC_MEASUREMENT = "sv_SE.UTF-8";
	    LC_MONETARY = "sv_SE.UTF-8";
	    LC_NAME = "sv_SE.UTF-8";
	    LC_NUMERIC = "sv_SE.UTF-8";
	    LC_PAPER = "sv_SE.UTF-8";
	    LC_TELEPHONE = "sv_SE.UTF-8";
	    LC_TIME = "sv_SE.UTF-8";
	  };

	  # Define a user account. Don't forget to set a password with ‘passwd’.
	  users.users.kog = {
	    isNormalUser = true;
	    description = "kog";
	  openssh.authorizedKeys.keys = [
	    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDakbytHYHeMYF4d37T3uOa5ILBFZ+LV25ViUMKiI5slozK56aRsZJrEPbQuLCt48uNkmY4yR1QztY3JCCysPRp4Co8Pi7YuYmd6DmU1k2f27JVno/K8DaGH7miPBLjcmoQguZFV460yirs7Rd4swQa9OMfBCtQ2w/rBga71yG9h6qNvF5csbBx8En8LIADvTsu+F61qQfQxhR37iUwozKmsbfMTiDu+p+n3T38RG8vuqBz3PSEXLQxLVel4ZdFcUvFz+yJc5qyRumTZO68QuWEI/D+FGSld8OHzlvUdELhhoK/986VmMhxR69Mv+ILa/7r0B3EkYO+xQqtHouf9s7GUyg2eSIjisbpVzZIEHcMx95bilJQkkIFHuFPX9gx595XZy0G3e7Wtc+HqDk/tJOFNXWKcO/BAgSCcqF6tZBsA7aJLH46pBhqxfxfykS9iMm3kTeFRZNmKEMQ9JRJnaaeyTxeEpX2sYwU4bqTaJojOJcHSKGGlfHefpkfzBnQNFk= kog@battlestation"
	    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpbCzlfMjlenM4qgaT4WWrVhtabWCBLN7X+JaXgInu40aiDEtKVyy6cTyyZmPv1BvHi1Xyg9coJxvlTv66EJZkzrf+UUvHTZhgcog6ZqAqOblxbk7wg2w+im/2TypVj5dvU8YRFz7dLcjA8tP0kyzXaPWEsA1KbVPV1jM+7ut41NldG7es+qxN0F9gvwmnHqS3ej2ajfGlXboGvWA4mcEF03YB9ZZKn7L2QTNRoajx1b83s+UYbRSSTi2xbSXNVmBGAKmO+TH0T+/1s4dR0inUzPX2UzpCXbwMCFwy0eNeO/MVQLoPdyVVc8YjTB8+nImnFRiaP6nTR0F3e+mQ3Xq1XBKyUpHe6tbxPL4coQOkciEcK8lq89pzbzc14ZVbIpnC35XZ2K3Bxk5U/8SjXpaxJ1SPBWOR7gn9XpeLZxOqwefR+K0OsQfTst8D7WRP8MxLYlBVzXnkKlewAYuwf6neQk0+ZqEmD4EdXwjY9Az+sDR676xgWQrfFcvRVRGIUWs= kog@Alexs-MacBook-Pro.local"
	  ];
	    extraGroups = [
		 "networkmanager" 
		 "wheel"
		 "docker"
	    ];
	    packages = with pkgs; [
		git
		zsh
		nmap
		lf    
	    ];
	  };

	  # Allow unfree packages
	  nixpkgs.config.allowUnfree = true;

	  # List packages installed in system profile. To search, run:
	  # $ nix search wget
	  environment.systemPackages = with pkgs; [
	    tree
	    wget
	    curl
	    vim
	    fzf
	    htop
	    cifs-utils
	    inetutils
	  ];

	  # Filesystem related settings

	  fileSystems."/mnt/media" = {
	      device = "//nas.reinthal.me/media";
	      fsType = "cifs";
	      options = let
		# this line prevents hanging on network split
		automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		permissions = "nobrl,dir_mode=0755,file_mode=0664,uid=1000,gid=100,noperm";
	      in ["${permissions},${automount_opts},credentials=/etc/nixos/smb-secrets"];
	  };
	# List services that you want to enable:

	services.qemuGuest.enable = true;
	services.openssh.enable = true;
	 
	# Configure keymap in X11
	services.xserver = {
	    layout = "us";
	    xkbVariant = "";
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.05"; # Did you read the comment?

}

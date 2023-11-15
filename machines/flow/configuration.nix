# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	  imports =
	    [ # Include the results of the hardware scan.
	      ./hardware-configuration.nix
              ../../modules/users.nix

	    ];

	  # Bootloader.
	  boot.loader.grub.enable = true;
	  boot.loader.grub.device = "/dev/sda";
	  boot.loader.grub.useOSProber = true;

	  networking.hostName = "flow"; # Define your hostname.

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
	      in ["${permissions},${automount_opts},credentials=/etc/smb-secrets"];
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

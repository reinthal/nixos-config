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
		../../modules/vm-services.nix
		../../modules/nice-to-have-packages.nix
		../../modules/tor.nix
		../../modules/zabbix.nix
	    ];
          system.autoUpgrade = {
            enable = true;
            flake = inputs.self.outPath;
            flags = ["--update-input" "nixpkgs" "-L"];
             dates = "02:00";
             randomizedDelaySec = "45min";
          };
	  # Bootloader.
	  boot.loader.grub.enable = true;
	  boot.loader.grub.device = "/dev/sda";
	  boot.loader.grub.useOSProber = true;
          
          # High Workload Server configs
          # https://github.com/Enkidu-6/tor-ddos?tab=readme-ov-file#first-step-preparing-your-system-for-high-number-of-connections

          boot.kernel.sysctl."net.ipv4.tcp_fin_timeout" = 20;
          boot.kernel.sysctl."net.ipv4.tcp_keepalive_time" = 1200;
          boot.kernel.sysctl."net.ipv4.tcp_syncookies" = 1;
          boot.kernel.sysctl."net.ipv4.tcp_tw_reuse" = 1;
          boot.kernel.sysctl."net.ipv4.ip_local_port_range" = "10000 65000";
          boot.kernel.sysctl."net.ipv4.tcp_max_syn_backlog" = 8192;
          boot.kernel.sysctl."net.ipv4.tcp_max_tw_buckets" = 5000;

	  networking = {
	     hostName = "relay"; # Define your hostname.
             networkmanager.enable = true;
             nftables.enable = true;
             firewall = {
  		enable = true;
                allowedTCPPorts = [ 22 80 443 10050];
	     };
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
	system.stateVersion = "23.11"; # Did you read the comment?

}

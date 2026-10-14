# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common.nix
    ../../features/sops.nix
    ../../features/cli/default.nix
  ];
  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = "25.11";
      isNvidia = false;
      secretsFile = ../../../secrets/shhh.yaml;
    };
    users = {
      kog = import ../../../home-manager/aligned-intelligence.nix;
    };
  };
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "aligned-intelligence"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Docker daemon (bash arena)
  virtualisation.docker.enable = true;

  # QEMU guest agent (host-side shutdown, IP reporting, fs freeze)
  services.qemuGuest.enable = true;

  # Tailscale: nixbook reaches this host via MagicDNS
  # (aligned-intelligence.tail2b04a.ts.net, see home-manager/gpg/forward-gpg-agent.nix).
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."kog" = {
    isNormalUser = true;
    description = "kog";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  services.openssh = {
    enable = true;
    # Needed so gpg-agent socket forwarding can replace a stale socket.
    settings.StreamLocalBindUnlink = true;
  };

  # Receive nixbook's forwarded gpg-agent socket (Yubikey signs here, see
  # home-manager/gpg/forward-gpg-agent.nix). No local agent or key material:
  #  - gpg client only, it talks to the forwarded socket
  #  - sshd can't bind into a missing dir, so create the socket dir at login
  #  - unlink a stale socket left by a previous session before binding
  environment.systemPackages = [pkgs.gnupg];
  systemd.user.tmpfiles.rules = ["d %t/gnupg 0700 - - -"];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "26.05"; # Did you read the comment?
}

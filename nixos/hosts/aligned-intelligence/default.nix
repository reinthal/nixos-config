# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
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

  # AIS-391: BashArena's sandbox router only DNATs TCP/80 to its fake external
  # 192.0.2.10; every other port was forwarded to the uplink and got us a
  # Hetzner portscan report. Never let documentation ranges (RFC 5737) or the
  # home LAN (seen leaking via tailscale NAT traversal) leave this VM.
  # Container traffic is filtered in DOCKER-USER: Docker inserts its own
  # FORWARD accepts above anything appended to FORWARD, but never touches
  # DOCKER-USER.
  networking.firewall = let
    # 185.199.108.153 (GitHub Pages) and 52.84.125.33 (CloudFront) are the
    # other two BashArena fake externals; only their TCP/80 is DNAT'd inside
    # the sandbox router, every other port would reach the real hosts.
    testNets = ["192.0.2.0/24" "198.51.100.0/24" "203.0.113.0/24" "185.199.108.153/32" "52.84.125.33/32"];
    homeLan = ["10.22.12.0/24"];
    block = extra: net: ''
      iptables -A egress-guard ${extra} -d ${net} -m limit --limit 10/min -j LOG --log-prefix "egress-guard: "
      iptables -A egress-guard ${extra} -d ${net} -j REJECT --reject-with icmp-admin-prohibited
    '';
  in {
    # Tailscale peers (nixbook) are trusted.
    trustedInterfaces = ["tailscale0"];
    extraCommands = ''
      iptables -N egress-guard 2>/dev/null || iptables -F egress-guard
      ${lib.concatMapStrings (block "") testNets}
      ${lib.concatMapStrings (block "! -o tailscale0") homeLan}
      iptables -N DOCKER-USER 2>/dev/null || true
      iptables -C DOCKER-USER -j egress-guard 2>/dev/null || iptables -I DOCKER-USER -j egress-guard
      iptables -C FORWARD -j egress-guard 2>/dev/null || iptables -I FORWARD -j egress-guard
      iptables -C OUTPUT -j egress-guard 2>/dev/null || iptables -I OUTPUT -j egress-guard
    '';
    extraStopCommands = ''
      iptables -D OUTPUT -j egress-guard 2>/dev/null || true
      iptables -D FORWARD -j egress-guard 2>/dev/null || true
      iptables -D DOCKER-USER -j egress-guard 2>/dev/null || true
      iptables -F egress-guard 2>/dev/null || true
      iptables -X egress-guard 2>/dev/null || true
    '';
  };

  # QEMU guest agent (host-side shutdown, IP reporting, fs freeze)
  services.qemuGuest.enable = true;

  # Tailscale: nixbook reaches this host via MagicDNS
  # (aligned-intelligence.tail2b04a.ts.net, see home-manager/gpg/forward-gpg-agent.nix).
  services.tailscale.enable = true;

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

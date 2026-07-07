{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../features/nas.nix
    ../../features/apps/docker.nix
    ../../features/apps/syncthing.nix
    ../../features/sops.nix
    ../../features/cli/default.nix
    # enable various features
    ../../features/sound.nix
    # key mappings
    # modules
    outputs.nixosModules.dual-function-keys
    ../../features/key-mappings/caps-to-ctrl-esc.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = "24.11";
      isNvidia = false;
      secretsFile = ../../../secrets/shhh.yaml;
    };
    users = {
      kog = import ../../../home-manager;
    };
  };

  # Bootloader.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable cross-compilation via QEMU user emulation
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  networking.hostName = "build"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Binary cache signing (daemon needs root-level key for builds)
  nix.settings.secret-key-files = ["/etc/nix/signing-key.sec"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pinentry-curses
  ];

  services = {
    tailscale.enable = true;
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    meilisearch.enable = false;
    journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=7day
    '';
  };
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
     ${pkgs.gnupg}/bin/gpg-connect-agent /bye
     export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  programs = {
    nix-ld.enable = true;
    ssh.startAgent = false;
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    gnupg.agent.pinentryPackage = pkgs.pinentry-curses;
  };

  # Allow forwarding a remote gpg-agent socket onto the standard agent path:
  # sshd unlinks the local agent's stale socket before binding the forward.
  # Lets nixbook's Yubikey sign here (see home-manager/gpg/forward-gpg-agent.nix).
  services.openssh.settings.StreamLocalBindUnlink = true;

  programs.zsh.enable = true;

  time.timeZone = "Europe/Stockholm";

  programs.dconf.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [9090 8188 8080 1716 9047 10300 2718];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

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
    ../../features/coms
    ../../features/nas.nix
    ../../features/apps/ollama.nix
    ../../features/apps/podman.nix
    ../../features/desktop
    ../../features/sops.nix
    ../../features/nvidia.nix

    ../../features/cli/devenvs/datalake-stack.nix
    
    # enable various features
    ../../features/sound.nix
    ../../features/bluetooth.nix
    # key mappings
    # modules
    outputs.nixosModules.dual-function-keys
    ../../features/key-mappings/caps-to-ctrl-esc.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {inherit pkgs inputs outputs;};
    users = {
      kog = import ../../../home-manager;
    };
  };

  # Bootloader.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "build"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnome-remote-desktop
    pinentry.curses
    droidcam
  ];

  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
  };
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
     ${pkgs.gnupg}/bin/gpg-connect-agent /bye
     export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  programs = {
    ssh.startAgent = false;
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    gnupg.agent.pinentryPackage = pkgs.pinentry.curses;
  };

  programs.zsh.enable = true;

  time.timeZone = "Europe/Stockholm";

  programs.dconf.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [8888 8080 3389];
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

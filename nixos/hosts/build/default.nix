{inputs,outputs,  pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../common.nix
      ../../features/coms
      ../../features/desktop

      # enable various features
      ../../features/sound.nix
      ../../features/bluetooth.nix
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "build"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    eza
    gnome.gnome-remote-desktop
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
  environment.systemPackages = with pkgs; [
    pinentry.curses
    droidcam
  ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3389 ];
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

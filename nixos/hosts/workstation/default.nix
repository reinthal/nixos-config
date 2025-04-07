# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  outputs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../features/coms
    ../../features/apps/podman.nix
    ../../features/desktop
    ../../features/sops.nix

    ../../features/cli/devenvs/datalake-stack.nix
    ../../features/cli/default.nix

    # enable various features
    ../../features/sound.nix
    # key mappings
    # modules
    outputs.nixosModules.dual-function-keys
    ../../features/key-mappings/caps-to-ctrl-esc.nix
    inputs.home-manager.nixosModules.default
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-0d811005-a4aa-4297-b870-89eb1fd778f7".device = "/dev/disk/by-uuid/0d811005-a4aa-4297-b870-89eb1fd778f7";
  networking.hostName = "workstation"; # Define your hostname.
  # Add rtl8812au driver
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8812au
  ];
  # Load the module at boot
  boot.kernelModules = ["8812au"];
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = "24.11";
    };
    users = {
      kog = import ../../../home-manager;
    };
  };

  environment.systemPackages = with pkgs; [
    usbutils
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

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kog = {
    isNormalUser = true;
    description = "kog";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

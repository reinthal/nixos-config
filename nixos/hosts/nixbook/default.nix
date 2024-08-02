# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../common.nix
    # apple-silicon hardware support
    inputs.apple-silicon.nixosModules.apple-silicon-support
    # Enable Nice Login-Screen
    #../../features/greetd.nix
    ../../features/coms
    ../../features/desktop
    
    (import ../../features/networking "nixbook")
    # enable various features
    ../../features/sound.nix
    ../../features/bluetooth.nix

    # font config
    ../../features/hidpi.nix
    # modules
    outputs.nixosModules.dual-function-keys
    outputs.nixosModules.v4l2-loopback
    
    # key mappings
    ../../features/key-mappings/caps-to-ctrl-esc.nix

    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;


  v4l2-loopback = {
    enable = true;
    devices = [
      {
        number = 0;
        label = "Droidcam";
      }
    ];
  };
  boot.kernelModules = [ "snd-aloop" ];

  # enable GPU support and audio
  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };

  # backlight control
  programs.light.enable = true;
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
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [225];
        events = ["key"];
        command = "/run/current-system/sw/bin/light -A 10";
      }
      {
        keys = [224];
        events = ["key"];
        command = "/run/current-system/sw/bin/light -U 10";
      }
    ];
  };

  time.timeZone = "Europe/Stockholm";
  # add the following line somewhere in `config#uration.nix`
  # for example, in between locales and audio sections

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {inherit pkgs inputs outputs;};
    users = {
      kog = import ../../../home-manager;
    };
  };
  programs.zsh.enable = true;
  # dconf
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    pinentry.curses
    droidcam
  ];
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}

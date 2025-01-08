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

    ../../features/apps/podman.nix
    ../../features/coms
    ../../features/desktop
    ../../features/sops.nix
    ../../features/cli/devenvs/datalake-stack.nix
    ../../features/nas.nix
    ../../features/daw.nix
    ../../features/cli
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
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [1716];
  };

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
    zsh.enable = true;
    dconf.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry.curses;
    };
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

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "e4da7455b22e6a55"
    ];
  };

  home-manager = {
    backupFileExtension = "hm-bkp";
    extraSpecialArgs = {
      inherit pkgs inputs outputs;
      stateVersion = config.system.stateVersion;
    };
    users = {
      kog = import ../../../home-manager;
    };
  };

  environment.systemPackages = with pkgs; [
    pinentry.curses
  ];
  specialisation = {
    plasma = {
      inheritParentConfig = false;
      configuration = {
        imports = [
          # Include the results of the hardware scan.
          ./hardware-configuration.nix
          ../../common.nix
          # apple-silicon hardware support
          inputs.apple-silicon.nixosModules.apple-silicon-support
          ../../features/apps/podman.nix
          ../../features/coms
          ../../features/plasma-desktop
          ../../features/sops.nix
          ../../features/cli/devenvs/datalake-stack.nix
          ../../features/nas.nix
          ../../features/cli
          (import ../../features/networking "nixbook")

          # enable various features
          ../../features/sound.nix
          ../../features/bluetooth.nix

          # font config
          ../../features/hidpi.nix
          # modules
          outputs.nixosModules.dual-function-keys
          # key mappings
          ../../features/key-mappings/caps-to-ctrl-esc.nix
        ];
        # Use the systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = false;

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [1716];
        };

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
          zsh.enable = true;
          dconf.enable = true;
          gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
            pinentryPackage = pkgs.pinentry.curses;
          };
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
        system.nixos.tags = ["plasma"];
        time.timeZone = "Europe/Stockholm";
        # add the following line somewhere in `config#uration.nix`
        # for example, in between locales and audio sections

        services.zerotierone = {
          enable = true;
          joinNetworks = [
            "e4da7455b22e6a55"
          ];
        };
        home-manager = {
          backupFileExtension = "hm-bkp";
          extraSpecialArgs = {
            inherit pkgs inputs outputs;
            stateVersion = config.system.stateVersion;
          };
          users = {
            kog = import ../../../home-manager/only-plasma.nix;
          };
        };
      };
    };
  };
  system.stateVersion = "24.11"; # Did you read the comment?
}

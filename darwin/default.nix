{pkgs, ...}: {
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  networking.hostName = "mbp";
  programs.zsh.enable = true;
  system.primaryUser = "kog";
  ids.gids.nixbld = 350;
  users.users.kog.home = "/Users/kog";
  environment = {
    shells = [pkgs.bash pkgs.zsh];
    systemPath = ["/opt/homebrew/bin"];
    pathsToLink = ["/Applications"];
    systemPackages = [pkgs.coreutils];
  };

  fonts.packages = [pkgs.nerd-fonts.meslo-lg];

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      finder.AppleShowAllExtensions = true;
      finder._FXShowPosixPathInTitle = true;
      dock = {
        autohide = true;
        # Configure hot corners
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 2;
        wvous-tr-corner = 2;
      };
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.InitialKeyRepeat = 14;
      NSGlobalDomain.KeyRepeat = 1;
    };
  };
  # backwards compat; don't change
  system.stateVersion = 4;

  # Homebrew
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;

    casks = [
      "signal"
      "vlc"
      "macfuse"
      "raycast"
      "visual-studio-code"
      "zed"
      "docker"
      "chromium"
    ];

    brews = [
      "helm"
      "yq"
      "trippy"
      "yubikey-personalization"
      "pinentry-mac"
      "ykman"
    ];

    masApps = {
      "Wireguard" = 1451685025;
      "Remote Desktop" = 1295203466;
    };
  };
}

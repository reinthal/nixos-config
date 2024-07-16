{pkgs, ...}: {
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.nix-daemon.enable = true;
  networking.hostName = "mbp";
  programs.zsh.enable = true;

  users.users.kog.home = "/Users/kog";
  environment = {
    shells = [pkgs.bash pkgs.zsh];
    loginShell = pkgs.zsh;
    systemPath = ["/opt/homebrew/bin"];
    pathsToLink = ["/Applications"];
    systemPackages = [pkgs.coreutils];
  };
  security.pam.enableSudoTouchIdAuth = true;

  fonts.packages = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];

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
    casks = ["signal" "vlc" "postman" "macfuse" "docker" "raycast" "amethyst" "visual-studio-code"];
    brews = ["helm" "yq" "trippy" "yubikey-personalization" "pinentry-mac" "ykman"];
    masApps = {
      "Wireguard" = 1451685025;
      "Remote Desktop" = 1295203466;
    };
  };
}

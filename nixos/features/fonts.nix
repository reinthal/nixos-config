{
  pkgs,
  lib,
  ...
}: {
  # Set the console font
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "sv_SE.UTF-8/UTF-8"
  ];
  console = {
    earlySetup = true;
    font = lib.mkDefault "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v16n.psf.gz";
    packages = [pkgs.powerline-fonts];
    keyMap = "us";
  };

  # Accept the license for the JoyPixels font
  nixpkgs.config.joypixels.acceptLicense = true;

  fonts.fontconfig = {
    enable = lib.mkForce true;
    defaultFonts = {
      serif = ["Liberation Serif" "Joypixels"];
      sansSerif = ["SF Pro Display" "Joypixels"];
      monospace = ["0xProto Nerd Font Mono"];
      emoji = ["Joypixels"];
    };
    # Fix pixelation
    antialias = true;
    # Fix antialiasing blur
    hinting = {
      enable = true;
      style = "full";
      autohint = true;
    };
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
  };
  fonts.packages =
    builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts)
    ++ builtins.attrValues {
      # Custom fonts from this repository (see pkgs/fonts)
      inherit (pkgs.local-pkgs.custom-fonts) material-icons feather-icons sf-pro monaspace;
    }
    ++ [pkgs.spleen];
}

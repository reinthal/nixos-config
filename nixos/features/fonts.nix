{
  pkgs,
  lib,
  ...
}: let
  nerdFonts = [
    pkgs.nerdfonts
  ];
in {
  # Set the console font
  i18n.defaultLocale = "en_US.UTF-8";
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
      monospace = ["FiraCode Nerd Font Mono"];
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
    [
      pkgs.nerdfonts
    ]
    ++ builtins.attrValues {
      inherit
        (pkgs)
        fira-code
        noto-fonts
        open-fonts
        powerline-fonts
        liberation_ttf
        iosevka
        joypixels
        ;
      # Custom fonts from this repository (see pkgs/fonts)
      inherit (pkgs.local-pkgs.custom-fonts) material-icons feather-icons sf-pro monaspace;
    };
}

{
  lib,
  pkgs,
  ...
}: let
  signal =
    if builtins.currentSystem == "x86_64-linux"
    then pkgs.signal-desktop
    else pkgs.signal-desktop-from-src;
in {
  imports = [
    ./data-eng.nix
    ./ags.nix
    ./kdeconnect.nix
  ];
  programs = {
    firefox = {
      enable = true;
    };

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
    };
  };

  home.packages = with pkgs;
    [
      networkmanagerapplet
      hyprshot
      # coms
      signal
    ]
    ++ lib.optional (builtins.currentSystem == "x86_64-linux") pkgs.slack;
  xdg = {
    enable = true;
    desktopEntries = {
      signal-desktop = {
        exec = "${lib.getExe' signal "signal-desktop"}";
        name = "Signal";
        type = "Application";
        terminal = false;
      };

      "org.gnome.Settings" = {
        name = "Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome-control-center}/bin/gnome-control-center";
        categories = ["X-Preferences"];
        terminal = false;
      };
    };
  };
}

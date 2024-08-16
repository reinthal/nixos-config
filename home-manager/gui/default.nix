{
  lib,
  pkgs,
  ...
}: {
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

  home.packages = with pkgs; [
    networkmanagerapplet
    hyprshot
    # coms
    signal-desktop-from-src
  ];
  xdg = {
    enable = true;
    desktopEntries = {
      signal-desktop = {
        exec = "${lib.getExe' pkgs.signal-desktop-from-src "signal-desktop"}";
        name = "Signal";
        type = "Application";
        terminal = false;
      };

      "org.gnome.Settings" = {
        name = "Settings";
        comment = "Gnome Control Center";
        icon = "org.gnome.Settings";
        exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome.gnome-control-center}/bin/gnome-control-center";
        categories = ["X-Preferences"];
        terminal = false;
      };
    };
  };
}

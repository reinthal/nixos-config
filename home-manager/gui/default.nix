{
  lib,
  pkgs,
  ...
}: let
  signal =
    if builtins.currentSystem == "x86_64-linux"
    then pkgs.signal-desktop
    else pkgs.signal-desktop-from-src;
  maybeSlack =
    if builtins.currentSystem == "x86_64-linux"
    then pkgs.slack
    else null;
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

  home.packages = with pkgs; [
    networkmanagerapplet
    hyprshot
    # coms
    signal
    maybeSlack
  ];
  xdg = {
    enable = true;
    desktopEntries = {
      signal-desktop = {
        exec = "${lib.getExe' signal "signal-desktop"}";
        name = "Signal";
        type = "Application";
        terminal = false;
      };

      slack-desktop = {
        exec = "${lib.getExe' maybeSlack "slack-desktop"}";
        name = "Slack";
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

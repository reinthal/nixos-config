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

  home.packages = with pkgs;
    [
      networkmanagerapplet
      zed-editor
      hyprshot
    ]
    ++ lib.optional (builtins.currentSystem == "x86_64-linux") [pkgs.slack pkgs.signal-desktop];
  xdg = {
    enable = true;
    #configFile."zed/settings.json".source = ./zed/settings.json;
    desktopEntries = {
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

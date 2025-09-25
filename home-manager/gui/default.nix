{
  lib,
  pkgs,
  ...
}: let
  # Packages used for interacting with OS
  shell-packages = with pkgs; [
    hyprshot
  ];
  desktop-apps = with pkgs;
    [
      anki
      obsidian
      networkmanagerapplet
      keepassxc
      remmina
      telegram-desktop
      mpv
    ]
    ++ lib.optionals (builtins.currentSystem == "x86_64-linux") [pkgs.slack pkgs.spotify pkgs.discord];
in {
  imports = [
    ./marble.nix
    ./kdeconnect.nix
    ./browser.nix
  ];
  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
        {id = "cclelndahbckbenkjhflpdbgdldlbecc";} # Get cookies.txt LOCALLY
        {id = "fihnjjcciajhdojfnbdddfaoknhalnja";} # i dont care about cookies
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
        {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # dark reader
        {id = "mnjggcdmjocbbbhaepdhchncahnbgone";} # sponsor block youtube
        {id = "nngceckbapebfimnlniiiahkandclblb";} # bitwarden
      ];
    };

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      package = pkgs.vscodium;
    };
  };

  home.packages = desktop-apps;
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

{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./data-eng.nix
    ./ags.nix
    ./kdeconnect.nix
    ./zen.nix
  ];
  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      extensions = [
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

  home.packages = with pkgs;
    [
      networkmanagerapplet
      inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
      ladybird
      qmmp
      code-cursor
      zed-editor
      hyprshot
      keepassxc
      remmina
      evolution
      signal-desktop
      telegram-desktop
      mpv
    ]
    ++ lib.optionals (builtins.currentSystem == "x86_64-linux") [pkgs.slack pkgs.spotify pkgs.discord];
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

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
      master.lmstudio
      anki
      libreoffice-qt6-fresh
      obsidian
      networkmanagerapplet
      keepassxc
      remmina
      telegram-desktop
      mpv
      prismlauncher
      reaper
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [pkgs.slack pkgs.spotify pkgs.discord];
in {
  imports = [
    ./waybar.nix
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
  };
}

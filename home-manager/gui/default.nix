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
      libreoffice-qt6-fresh
      obsidian
      networkmanagerapplet
      keepassxc
      remmina
      mpv
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
        {id = "fcoeoabgfenejglbffodgkkbkcdhcgfn";} # claude
      ];
    };
    ghostty = {
      enable = true;
      enableZshIntegration = true;
    };
    vscode = {
      enable = true;
      mutableExtensionsDir = true;
    };
    vscodium = {
      enable = true;
      mutableExtensionsDir = true;
      # vscode and vscodium share files (e.g. LICENSES.chromium.html), which
      # collide in the home-manager-path buildEnv. Lower vscodium's priority so
      # the conflict resolves in favour of vscode; both editors still install.
      package = lib.lowPrio pkgs.vscodium;
    };
  };

  home.packages = desktop-apps;
  xdg = {
    enable = true;
  };
}

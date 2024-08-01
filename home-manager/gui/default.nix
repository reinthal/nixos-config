{
  lib,
  pkgs,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
    };

    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };

  };

  home.packages = with pkgs; [
    networkmanagerapplet
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
    };
  };
}


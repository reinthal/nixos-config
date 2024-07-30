{ lib, pkgs, ... }: {
    home.packages = with pkgs; [
        networkmanagerapplet
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
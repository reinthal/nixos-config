{ config, pkgs, ... }:
{
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        pciutils
        tree
        wget
        curl
        vim
        htop
        inetutils
    ];
}

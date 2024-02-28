

{ config, pkgs, ... }:
{
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs;
  [
  firefox
  ];
}

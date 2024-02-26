
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vscodium
    firefox
  ];


}

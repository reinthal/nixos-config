
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ vscode.fhs ];
  programs.nix-ld.enable = true;
}


{ config, pkgs, ... }:
{
  imports = [
    <nix-ld/modules/nix-ld.nix>
    (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  ];
  services.vscode-server.enable = true;

  programs.nix-ld.dev.enable = true;  
  environment.systemPackages = with pkgs; [ vscode vscode.fhs ];

}

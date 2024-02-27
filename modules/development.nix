
{ config, pkgs, ... }:
{
  imports = [
    <nix-ld/modules/nix-ld.nix>
  ];
  #imports = [
  #  (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
  #];

  #services.vscode-server.enable = true;
  # The module in this repository defines a new module under (programs.nix-ld.dev) instead of (programs.nix-ld) 
  # to not collide with the nixpkgs version.
  programs.nix-ld.dev.enable = true;  
  environment.systemPackages = with pkgs; [ vscode vscode.fhs ];

}

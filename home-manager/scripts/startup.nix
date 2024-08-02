{
  pkgs,
  lib,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.swww}/bin/swww init &
      export XKB_DEFAULT_LAYOUT=us
      export XCURSOR_THEME=Qogir
    sleep 1
    ${pkgs.networkmanagerapplet}/bin/nm-applet --no-agent &
    ${pkgs.swww}/bin/swww img ${../../img/red.jpg} &
  '';
in
{
    home.packages = [startupScript];
}
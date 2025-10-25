{pkgs, ...}: let
  switch = pkgs.writeShellScriptBin "switch" ''
    FF_BKP=$HOME/.mozilla/firefox/default/search.json.mozlz4.hm-bkp
    if [ -f $FF_BKP ]; then
       rm $FF_BKP;
    fi
    HOSTNAME=$(${pkgs.hostname}/bin/hostname)
    sudo nixos-rebuild switch --flake ~/nixos-config#$HOSTNAME --impure
  '';
in {
  home.packages = [switch];
}

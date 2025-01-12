{
  pkgs,
  inputs,
  ...
}: let
  hyprctl-reload =
    pkgs.writeShellScriptBin "hyprctl-reload"
    ''
        until [[ -n \"$HYPRLAND_INSTANCE_SIGNATURE\" ]]; do
        echo \"Waiting for Hyprland to start...\"
        sleep 1
        HYPRLAND_INSTANCE_SIGNATURE=$(env | grep HYPRLAND_INSTANCE_SIGNATURE)
      done
      echo \"Hyprland is ready! Running hyprctl reload...\"
      ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl reload
    '';
in {
  home.packages = [hyprctl-reload];
}

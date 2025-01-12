{
  pkgs,
  inputs,
  ...
}: let
  hyprctl-reload =
    pkgs.writeShellScriptBin "hyprctl-reload"
    ''
        until [[ -n \"$AGS_RUNNING_INSTANCE\" ]]; do
        echo \"Waiting for Hyprland to start...\"
        sleep 1
        AGS_RUNNING_INSTANCE=$(ps aux | grep agr-wrapped)
      done
      echo \"Ags is ready! Running hyprctl reload...\"
      ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl reload
    '';
in {
  home.packages = [hyprctl-reload];
}

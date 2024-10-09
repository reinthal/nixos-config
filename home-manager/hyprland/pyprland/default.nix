{
  pkgs,
  inputs,
  ...
}: let
  pyprland = inputs.pyprland.packages.${pkgs.system}.pyprland;
in {
  home.packages = [
    pyprland
  ];

  xdg.configFile."hypr/pyprland.toml".text = ''
        [pyprland]
        plugins = [
          # Easily toggle the visibility of applications: https://hyprland-community.github.io/pyprland/scratchpads.html.
          "scratchpads",
          # Implements a workspace layout where one window is bigger and centered, other windows are tiled as usual in the background: https://hyprland-community.github.io/pyprland/layout_center.html
          "layout_center"
        ]
    [scratchpads.knowit_slack]
    command = "brave --profile-directory=Default --app=https://app.slack.com/client/T02MLJA4G/C06DHG3NJTS"
    animation = "fromBottom"
    class = "brave-web.knowit_slack.com__-Default"
    lazy = true
    margin = 10
    size = "90% 90%"
    unfocus = "hide"
  '';
}

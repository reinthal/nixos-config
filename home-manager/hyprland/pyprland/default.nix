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

          # Implements a workspace layout where one window is bigger and centered,
          # other windows are tiled as usual in the background: https://hyprland-community.github.io/pyprland/layout_center.html
          "layout_center"
        ]
        [scratchpads.ident]
        command = "firefox https://ident.me"
        animation = "fromTop"
    class = "firefox-ident"
    size = "75% 60%"
    max_size = "1920px 100%"
    margin = 50

            [scratchpads.slack]
        command = "brave --profile-directory=Default --app=https://app.slack.com/client/T02MLJA4G/C06DHG3NJTS"
        animation = "fromTop"
        class = "brave-web.slack.com__-Default"
        margin = 10
        size = "90% 90%"

    [scratchpads.term]
    animation = "fromTop"
    command = "kitty --class kitty-dropterm"
    class = "kitty-dropterm"
    size = "75% 60%"
    max_size = "1920px 100%"
    margin = 50

    [scratchpads.volume]
    animation = "fromRight"
    command = "pavucontrol"
    class = "org.pulseaudio.pavucontrol"
    size = "40% 90%"
    unfocus = "hide"
    lazy = true
  '';
}

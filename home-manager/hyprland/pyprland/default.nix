{
  pkgs,
  inputs,
  ...
}: let
  pyprland = inputs.pyprland.packages.${pkgs.stdenv.hostPlatform.system}.pyprland;
in {
  home.packages = [
    pyprland
  ];

  xdg.configFile."hypr/pyprland.toml".text =  builtins.readFile ./pyprland.toml;
}

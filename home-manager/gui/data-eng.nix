{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];
  home = {
    sessionVariables = {
      GTK_IM_MODULE = "ibus";
    };
  };
}

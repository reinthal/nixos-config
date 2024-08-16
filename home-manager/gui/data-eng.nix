{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    dbeaver-bin
  ];
  home = {
    sessionVariables = {
      GTK_IM_MODULE = "ibus";
    };
  };
}

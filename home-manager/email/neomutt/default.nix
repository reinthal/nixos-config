{pkgs, ...}: let
  colorscheme = (import ./colorscheme.nix).colorscheme;
in {
  programs = {
    neomutt = {
      enable = true;
      sidebar = {
        width = 40;
        enable = true;
        shortPath = true;
        format = "%D%> %?N?%N/?%S";
      };
      vimKeys = true;
      sort = "reverse-date";
      extraConfig = ''
        ${colorscheme}
      '';
    };
  };
}

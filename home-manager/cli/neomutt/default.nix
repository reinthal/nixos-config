{pkgs, ...}: let
  colorscheme = (import ./neomutt_colorscheme.nix).colorscheme;
in {
  accounts.email = {
    maildirBasePath = "mail";

  };

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

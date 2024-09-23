{pkgs}: let
  colorscheme = (import ./neomutt_colorscheme.nix).colorscheme;
in {
  programs = {
    accounts.email = {
      maldirBasePath = "mail";
    };
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

{pkgs, ...}: {
  programs = {
    kitty = {
      enable = true;
      themeFile = "Catppuccin-Frappe";
      font = {
        name = "EnvyCodeR Nerd Font Propo";
        size = 12;
      };
    };
  };
}

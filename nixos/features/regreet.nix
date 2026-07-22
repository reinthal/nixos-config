{
  pkgs,
  lib,
  config,
  ...
}: {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  environment.etc."greetd/hyprland.lua".text = ''
    hl.on("hyprland.start", function()
        hl.exec_cmd("regreet; hyprctl dispatch 'hl.dsp.exit()'")
    end)
    hl.config({
        misc = {
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            disable_hyprland_guiutils_check = true,
        },
    })
  '';

  programs.regreet = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    cursorTheme = {
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
    };
    iconTheme = {
      name = "Qogir";
      package = pkgs.qogir-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 12;
    };
  };
}

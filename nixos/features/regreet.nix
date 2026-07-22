{pkgs, ...}: {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # ReGreet: GTK greeter for greetd. programs.regreet.enable also enables greetd
  # and runs the greeter inside cage (a minimal KMS/DRM Wayland compositor), so
  # it uses the GPU path — not the legacy fbcon/framebuffer path that hung
  # tuigreet on Asahi 7.0.13.
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

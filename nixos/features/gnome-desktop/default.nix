# GNOME Shell as an *alternative* session alongside Hyprland.
#
# Deliberately does NOT enable a display manager of its own (no GDM): the
# greeter comes from ../desktop -> ../regreet.nix. GNOME only registers its
# session through services.displayManager.sessionPackages, so ReGreet lists
# "gnome" next to "hyprland" in its session dropdown and the pick happens at
# login.
{pkgs, ...}: {
  services.desktopManager.gnome.enable = true;

  # GNOME keeps its settings in dconf.
  programs.dconf.enable = true;

  # Drop core-apps that duplicate what ../desktop and ../cli already install,
  # plus the first-run fluff.
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-console # we bring our own terminal
    epiphany
    gnome-music
    showtime
  ];
}

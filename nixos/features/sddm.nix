{...}: {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "weston";
    };
  };

  # Hyprland session entry is provided by programs.hyprland.enable
  # (installs a wayland-sessions desktop file), so SDDM auto-lists it.
}

{lib, ...}: {
  # Hyprland ships no polkit authentication agent on its own, so every
  # polkit action that needs auth (fprintd enroll, GUI privilege prompts,
  # mounting, etc.) is denied outright with "Not Authorized" and no prompt.
  # hyprpolkitagent provides the graphical password/fingerprint prompt.
  services.hyprpolkitagent.enable = true;

  # GNOME (the other session offered on framebook) brings gnome-shell's own
  # polkit agent; don't start a second one there. Same guard as hypridle and
  # hyprctl-reload (home-manager/hyprland/hyprland.nix, framebook.nix).
  systemd.user.services.hyprpolkitagent.Unit.ConditionEnvironment =
    lib.mkForce ["WAYLAND_DISPLAY" "!XDG_CURRENT_DESKTOP=GNOME"];
}

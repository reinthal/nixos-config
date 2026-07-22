{
  pkgs,
  lib,
  config,
  ...
}: {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # greetd + ReGreet. ReGreet is a GTK greeter that runs as a Wayland client.
  # Here it runs inside a real Hyprland instance (not cage): greetd launches
  # Hyprland with /etc/greetd/hyprland.lua, which execs regreet on start and
  # exits Hyprland when regreet returns. Uses the exact same compositor +
  # KMS/DRM/GPU path as the post-login session — sidesteps the legacy fbcon
  # path that hung tuigreet on Asahi 7.0.13.
  services.greetd.enable = true;

  # Greeter Hyprland config (Lua). Root-owned via /etc — greetd runs as root.
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

  # Run the greeter inside Hyprland instead of the cage default that
  # programs.regreet sets. mkForce overrides that default_session.
  services.greetd.settings.default_session.command = lib.mkForce ''
    ${config.programs.hyprland.package}/bin/Hyprland --config /etc/greetd/hyprland.lua
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

  # ReGreet lists both hyprland wayland-sessions (plain and uwsm). The uwsm
  # variant fails on nixbook (systemctl --user start
  # wayland-session-bindpid@.service exits 5). Pick "Hyprland" (not
  # "uwsm-managed") in the greeter — ReGreet remembers the last choice in
  # /var/lib/regreet/cache.toml.
}

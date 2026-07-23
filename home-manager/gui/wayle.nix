{...}: {
  # Wayle: Rust/GTK4 Wayland shell (successor to HyprPanel by the same author).
  # Runs as a systemd user service bound to the graphical session; no exec-once
  # needed. Package (pkgs.wayle) and this module both ship in nixpkgs-unstable /
  # home-manager master, so no extra flake input.
  services.wayle = {
    enable = true;

    # Pull in wallust/matugen/aww etc. only if the config below references them.
    autoInstallDependencies = true;

    settings = {
      bar = {
        background-opacity = 50;
        bg = "bg-base";
        scale = 0.8;
        layout = [
          {
            monitor = "*";
            show = true;
            left = ["dashboard" "hyprland-workspaces" "window-title" "media"];
            center = [];
            right = [
              {
                name = "sys";
                modules = [];
              }
              "network"
              "battery"
              "notifications"
              "clock"
              "weather"
              "power"
            ];
          }
        ];
      };
      general = {
        font-mono = "0xProto Nerd Font";
        font-sans = "UbuntuSans Nerd Font";
      };
      modules = {
        hyprland-workspaces = {
          app-icons-show = true;
          border-show = true;
        };
        weather = {
          time-format = "24h";
        };
      };
      styling = {
        palette = {
          bg = "#333c43";
          blue = "#83c092";
          elevated = "#4d5960";
          fg = "#d3c6aa";
          fg-muted = "#859289";
          green = "#a7c080";
          primary = "#7fbbb3";
          red = "#e67e80";
          surface = "#3a464c";
          yellow = "#dbbc7f";
        };
      };
    };
  };
}

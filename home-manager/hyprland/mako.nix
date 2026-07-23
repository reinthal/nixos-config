{pkgs, ...}: {
  services.batsignal = {
    enable = true;
  };
  services.mako = {
    # Disabled: wayle's `notifications` module is the notification daemon now.
    # Two daemons race for org.freedesktop.Notifications. batsignal (above)
    # stays — it just emits notifications into wayle's daemon.
    enable = false;

    settings = {
      # Font matching your system's default
      font = "SF Pro Display 11";

      # Dimensions
      width = 400;
      height = 150;
      margin = "10";
      padding = "15";

      # Nord theme colors
      background-color = "#2e3440";
      text-color = "#d8dee9";
      border-color = "#88c0d0";
      border-size = 2;
      border-radius = 10; # Matches Hyprland rounding

      # Icons - use hicolor (includes your custom icons) + fallback to Adwaita
      icon-path = "${pkgs.hicolor-icon-theme}/share/icons/hicolor:${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
      max-icon-size = 64;

      # Position
      anchor = "top-right";

      # Behavior
      default-timeout = 5000;
      ignore-timeout = false;

      # Progress bar styling
      progress-color = "over #4c566a";
    };

    # Per-urgency styling with Nord colors
    extraConfig = ''
      [urgency=low]
      border-color=#5e81ac
      background-color=#2e3440

      [urgency=normal]
      border-color=#88c0d0
      background-color=#2e3440

      [urgency=critical]
      border-color=#bf616a
      background-color=#2e3440
      text-color=#bf616a
      default-timeout=0
    '';
  };
}

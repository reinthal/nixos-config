{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../sddm.nix
  ];
  services = {
    xserver.enable = true;
    # Grant seat users access to /sys/class/backlight for brightnessctl.
    udev.packages = [pkgs.brightnessctl];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # wayland-related
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [
    morewaita-icon-theme
    adwaita-icon-theme
    qogir-icon-theme
    # Image Viewer
    loupe
    # file system tool
    nautilus
    # disk utility
    baobab
    # Wayland /  Hyprland
    libnotify
    wl-gammactl
    fuzzel
    bzmenu
    iwmenu
    pwmenu
    # Backlight control for hyprland media keys
    brightnessctl
  ];
}

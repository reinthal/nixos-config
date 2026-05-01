{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../greetd.nix
  ];
  services = {
    xserver.enable = true;
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
    rofi
  ];
}

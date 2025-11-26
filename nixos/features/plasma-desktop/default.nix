{pkgs, ...}: {
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    xserver.enable = true;
  };

  # wayland-related
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [
    morewaita-icon-theme
    adwaita-icon-theme
    qogir-icon-theme
    brave
    baobab
  ];
}

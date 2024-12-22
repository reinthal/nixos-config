{pkgs, ...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "kog";
  };
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}

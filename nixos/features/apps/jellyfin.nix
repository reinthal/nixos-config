{pkgs, ...}: {
  services.meilisearch = {
    enable = true;
    environment = "production";
  };
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

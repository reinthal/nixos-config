{
  pkgs,
  config,
  ...
}: {
  services.meilisearch = {
    enable = true;
    environment = "production";
    masterKeyEnvironmentFile = /var/lib/meilisearch/auth/master.key;
    package = pkgs.unstable.meilisearch;
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

{
  pkgs,
  config,
  ...
}: {
  sops.secrets."meilisearch/master_key" = {
    owner = "65367";
    group = "65367";
  };

  services.meilisearch = {
    enable = true;
    environment = "production";
    package = pkgs.unstable.meilisearch;
    masterKeyEnvironmentFile = /var/lib/meilisearch/auth/master.key;
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

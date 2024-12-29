{
  config,
  pkgs,
  ...
}: {
  config.systemd.tmpfiles.rules = ["d /home/kog/.navidrome 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    navidrome = {
      image = "deluan/navidrome:latest";

      extraOptions = [
        "--hostname"
        "flix"
      ];

      ports = [
        "8095:4533" # Navidrome web interface and API
      ];

      environment = {
        PUID = "1000";
        PGID = "100";
        ND_SCANINTERVAL = "1h";
        ND_LOGLEVEL = "info";
        ND_ENABLESHARING = "true";
        ND_BASEURL = "https://music.reinthal.me";
        ND_REVERSEPROXYWHITELIST = "10.22.10.18";
      };

      volumes = [
        "/home/kog/.navidrome:/data" # Navidrome configuration and database
        "/mnt/media/media/music:/music:ro" # Music directory (read-only)
      ];
    };
  };
}

{
  config,
  pkgs,
  ...
}: {
  config.systemd.tmpfiles.rules = ["d /home/kog/.pinchflat 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    pinchflat = {
      image = "ghcr.io/kieraneglin/pinchflat:latest";
      user = "1000:1000";
      extraOptions = [
        "--hostname"
        "flix"
      ];

      ports = [
        "8945:8945" # Pinchflat web interface
      ];

      environment = {
        TZ = "Europe/Stockholm";
      };

      volumes = [
        "/home/kog/.pinchflat:/config" # Pinchflat configuration
        "/mnt/media/media/youtube:/downloads" # YouTube downloads directory
        "/home/kog/.config/yt-dlp.txt:/config/extras/cookies.txt:ro" # yt-dlp cookies
      ];
    };
  };
}

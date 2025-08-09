{
  config,
  pkgs,
  ...
}: {
  config.systemd.tmpfiles.rules = ["d /home/kog/.pinchflat 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    pinchflat = {
      image = "ghcr.io/kieraneglin/pinchflat:latest";

      extraOptions = [
        "--hostname"
        "flix"
      ];

      ports = [
        "8945:8945" # Pinchflat web interface
      ];

      environment = {
        TZ = "Europe/Stockholm";
        PUID = "1000";
        PGID = "1000";
      };

      volumes = [
        "/home/kog/.pinchflat:/config" # Pinchflat configuration
        "/mnt/media/media/youtube:/downloads" # YouTube downloads directory
      ];
    };
  };
}


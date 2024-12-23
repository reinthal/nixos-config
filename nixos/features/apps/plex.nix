{
  config,
  pkgs,
  ...
}: {
  config.systemd.tmpfiles.rules = ["d /home/kog/.plex 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    plex = {
      # Use the same image as in your Docker Compose file
      image = "lscr.io/linuxserver/plex:latest";

      # Container hostname
      extraOptions = [
        "--hostname"
        "flix"
        "--device"
        "nvidia.com/gpu=all"
      ];

      # Forward essential ports for Plex
      ports = [
        "32400:32400/tcp" # Plex web interface
        "32469:32469/tcp" # DLNA
        "1900:1900/udp" # UPnP service discovery
        "3005:3005/tcp" # Remote control
      ];

      # Environment variables for Plex
      environment = {
        PUID = "1000";
        PGID = "100";
        VERSION = "docker";
        NVIDIA_VISIBLE_DEVICES = "all"; # Expose all NVIDIA GPUs to the container
        NVIDIA_DRIVER_CAPABILITIES = "all"; # Enable all GPU capabilities
      };

      # Volume mounts
      volumes = [
        "/home/kog/.plex:/config" # Plex configuration path
        "/mnt/media/media/transcodes/cache:/config/Library/Application Support/Plex Media Server/Cache/" # Cache path
        "/mnt/media/media/transcodes:/transcodes" # Transcode directory
        "/mnt/media/media:/media" # Media directory
      ];
    };
  };
}

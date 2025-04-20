{
  config,
  pkgs,
  ...
}: let
  data_path = "/home/kog/.piper";
in {
  config.systemd.tmpfiles.rules = ["d ${data_path} 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    piper = {
      image = "docker.io/rhasspy/wyoming-piper:latest";
      ports = ["10200:10200"];
      extraOptions = [
        "--device"
        "nvidia.com/gpu=all"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        UMASK = "002";
        TZ = "Etc/Stockholm";
      };
      volumes = [
        "${data_path}:/data"
      ];
      cmd = [
        "--voice"
        "en_US-lessac-high"
        "--uri"
        "tcp://0.0.0.0:10200"
        "--data-dir"
        "/data"
        "--download-dir"
        "/data"
      ];
    };
  };
}

{
  config,
  pkgs,
  ...
}: let
  data_path = "/home/kog/.whisper";
in {
  config.systemd.tmpfiles.rules = ["d ${data_path} 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    whisper = {
      image = "docker.io/rhasspy/wyoming-whisper:latest";
      ports = ["10300:10300"];
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
        "--model"
        "large-v3"
        "--language"
        "en"
        "--uri"
        "tcp://0.0.0.0:10300"
        "--data-dir"
        "/data"
        "--download-dir"
        "/data"
      ];
    };
  };
}

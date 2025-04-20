{
  config,
  pkgs,
  ...
}: let
  data_path = "/home/kog/.openwakeword";
in {
  config.systemd.tmpfiles.rules = ["d ${data_path} 770 kog users -"];
  config.virtualisation.oci-containers.containers = {
    openwakeword = {
      image = "docker.io/rhasspy/wyoming-openwakeword:latest";
      ports = ["10400:10400"];
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
        "--preload-model"
        "ok_nabu"
        "--uri"
        "tcp://0.0.0.0:10400"
        "--custom-model-dir"
        "/custom"
      ];
    };
  };
}

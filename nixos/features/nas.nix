{
  config,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = ["nfs"];
  fileSystems = {
    "/mnt/wlots" = {
      device = "nas.reinthal.me:/mnt/tonberry/wlots";
      fsType = "nfs";
      options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30" "soft"];
    };
    "/mnt/anime" = {
      device = "nas.reinthal.me:/mnt/cactuar/anime";
      fsType = "nfs";
      options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30" "soft"];
    };

    "/mnt/media" = {
      device = "nas.reinthal.me:/mnt/tonberry/media";
      fsType = "nfs";
      options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30" "soft"];
    };
  };
}

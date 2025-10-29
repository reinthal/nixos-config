{
  config,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = ["nfs"];
  fileSystems."/mnt/anime" = {
    device = "nas.reinthal.me:/mnt/cactuar/anime";
    fsType = "nfs";
    options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30" "soft"];
  };

  fileSystems."/mnt/media" = {
    device = "nas.reinthal.me:/mnt/tonberry/media";
    fsType = "nfs";
    options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30" "soft"];
  };
}

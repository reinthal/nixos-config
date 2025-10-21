{
  config,
  pkgs,
  ...
}: {
  boot.supportedFilesystems = ["nfs"];
  fileSystems."/mnt/media" = {
    device = "nas.reinthal.me:/mnt/tonberry/media";
    fsType = "nfs";
    options = ["noauto" "x-systemd.automount" "x-systemd.device-timeout=30" "soft"];
  };
}

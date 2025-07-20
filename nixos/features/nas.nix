{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [nfs-utils];
  # Filesystem related settings
  fileSystems."/mnt/media" = {
    device = "nas.reinthal.me:/mnt/tonberry/media";
    fsType = "nfs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      nfs_opts = "vers=4,rsize=1048576,wsize=1048576,hard,intr";
    in ["${nfs_opts},${automount_opts}"];
  };
}

{ config, pkgs, ... }:

{
    

    environment.systemPackages = with pkgs; [cifs-utils];
    # Filesystem related settings
    fileSystems."/mnt/skff" = {
        device = "//nas.reinthal.me/skff";
        fsType = "cifs";
        options = let
    # this line prevents hanging on network split
    automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    permissions = "nobrl,dir_mode=0755,file_mode=0664,uid=1337,gid=100,noperm";
        in ["${permissions},${automount_opts},credentials=/etc/smb-secrets"];
    };
}

{ config, pkgs, ... }:
 {
   config.virtualisation.oci-containers.containers = {
     qbittorrent = {
       image = "lscr.io/linuxserver/plex:latest";
       ports = ["32400:32400"];
       environment = {
          PUID = "1000";
          PGID = "1000";
          UMASK = "002";
          TZ="Etc/Stockholm";
       };
       volumes = [
         "/home/kog/appdata/plex:/config"
         "/mnt/media/media/transcodes:/transcodes"
         "/mnt/media/media/transcodes/cache:/config/Library/Application Support/Plex Media Server/Cache/"
         "/mnt/media/media/:/media"
       ];
     };
   };
 }

